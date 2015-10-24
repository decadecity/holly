# Description
#   Generate chat messages using markov chains.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Holly markov - post a markov message based on the past N chat messages
#   Holly markov <user> - post a markov message based on chat messages made by <user>
#   Holly markov <url> - post a markov message based on contents of the provided web page (very basic)
#   Holly markov learn <url>|<text> - add the contents of the URL or supplied text to the messageCache
#   Holly markov reset - reset the message messageCache
#
# Notes:
#   None
#
# Author:
#   sunpig
#   decadecity

util = require 'util'
request = require 'request'
cheerio = require 'cheerio'
own_name = 'holly'


IGNORE_USERS = [own_name] # lowercase
MAX_MESSAGE_CACHE_LENGTH = 2500 # too small = such boring, too big = very memory
MAX_GENERATED_MESSAGE_LENGTH = 200 # die soon in case of infinite looping case
ASK_HUBOT_REGEX = new RegExp('^(.*)' + own_name + '\\?$', 'i')
OWN_NAME_REGEX = new RegExp('^' + own_name, 'i')


generateMessage = (msg, corpus) ->
  if corpus.length == 0
    return 'There are no messages for building a chain.'
  else
    transitions = generateTransitions(corpus)

    startWords = (word for own word, data of transitions when word.length and data.begins == true)

    word = msg.random(startWords)
    generatedMessage = [word]

    next = msg.random(transitions[word].list)

    i = 0
    while (i++ < MAX_GENERATED_MESSAGE_LENGTH)
      generatedMessage.push(next.word)
      if next.ends
        return generatedMessage.join(' ')
      else
        next = msg.random(transitions[next.word].list)


generateTransitions = (corpus) ->
  saidSplitter = /\s/
  transitions = {}

  for said in corpus
    words = []
    for word in said.split(saidSplitter)
      if word.length
        words.push word

    for i in [0..(words.length - 1)]
      word = words[i]

      transition = transitions[word]
      if not transition
        transition = {
          begins: (i == 0),
          list: []
        }

      transition.list.push({
        word: words[i + 1],
        ends: (i == words.length - 1)
      })

      transitions[word] = transition

  return transitions


sendGenericMarkov = (robot, msg) ->
  messageCache = robot.brain.data.markov.messageCache
  corpus = (message.said for message in messageCache)
  message = generateMessage(msg, corpus)
  msg.send message


sendMarkovForUrl = (url, msg) ->
  request url, (err, res, body) ->
    $ = cheerio.load body,
      normalizeWhitespace: true
      xmlMode: false
    corpus = []
    $('script').remove()
    $('p').each (index, el) ->
      text = $(this).text().trim()
      if text.split(/\s/).length < 3
        corpus.push text
    try
      msg.send generateMessage(msg, corpus)
    catch e
      msg.send "There was an error generating a Markov chain"


learnMarkovForUrl = (robot, url, msg) ->
  request url, (err, res, body) ->
    messageCache = robot.brain.data.markov.messageCache
    $ = cheerio.load body,
      normalizeWhitespace: true
      xmlMode: false
    corpus = []
    $('script').remove()
    $('p').each (index, el) ->
      text = $(this).text().trim()
      if text.split(/\s/).length < 3
        corpus.push text
        messageCache.push({user: own_name, said: text})

    try
      message = generateMessage(msg, corpus)
      msg.send "IQ increased by " + message.length
      robot.brain.data.iq.current = robot.brain.data.iq.current + message.length
      robot.brain.data.iq.time = new Date()

    catch e
      msg.send "IQ failed to increase."


module.exports = (robot) ->

  robot.brain.on 'loaded', =>
    robot.brain.data.markov ||= {}
    robot.brain.data.markov.messageCache ||= []


  robot.respond /markov\s*?$/i, (msg) ->
    sendGenericMarkov(robot, msg)


  # Show transitions for a word.
  robot.respond /markov-transitions (\w+)/i, (msg) ->
    messageCache = robot.brain.data.markov.messageCache
    corpus = (message.said for message in messageCache)
    transitions = generateTransitions(corpus)

    transition = transitions[msg.match[1]] || {list:[]}

    words = {}
    for t in transition.list
      if t.word
        count = words[t.word] || 0
        count += 1
        words[t.word] = count

    if !Object.keys(words).length
      message = 'No transitions found '
    else
      message = ''
      for word, count of words
        message = message + word + ':' + count + '\n'

    msg.send message.substring(0, message.length - 1);


  # Respond to questions like "what do you think, hubot?"
  robot.hear ASK_HUBOT_REGEX, (msg) ->
    sendGenericMarkov(robot, msg)


  robot.respond /markov (?:(?!reset|learn))(.*)$/i, (msg) ->
    if msg.match[1] and msg.match[1].match /https?:\/\/\S+/
      url = msg.match[1]
      sendMarkovForUrl(url, msg)
    else
      lcUserName = msg.match[1].trim().toLowerCase()
      messageCache = robot.brain.data.markov.messageCache
      corpus = (message.said for message in messageCache when message.user == lcUserName)
      msg.send generateMessage(msg, corpus)


  robot.respond /markov learn (?:(?!reset))(.*)$/i, (msg) ->
    if msg.match[1] and msg.match[1].match /https?:\/\/\S+/
      url = msg.match[1]
      learnMarkovForUrl(robot, url, msg)
    else
      said = msg.match[1]
      if said.length
        messageCache = robot.brain.data.markov.messageCache
        messageCache.push({user: own_name, said: said.trim()})
        message = generateMessage(msg, said)
        msg.send "IQ increased by " + message.length


  robot.respond /markov reset/i, (msg) ->
    robot.brain.data.markov.messageCache = []
    msg.send "The Markov cache has been reset."


  robot.hear /(.*)/i, (msg) ->
    # Ignore messages from specific users
    userName = msg.message.user.real_username || msg.message.user.name
    lcUserName = userName.toLowerCase()
    return if (lcUserName in IGNORE_USERS)

    # Ignore messages containing links
    said = msg.match[1]
    return if said.match(/https?:\/\//gi)

    # Ignore empty or one-word messages
    said = msg.match[1]
    return if said.split(/\s/).length < 2

    # Ignore hubot instructions
    return if said.match(OWN_NAME_REGEX)

    # Stop hubot learning to ask itself questions.
    _ask_hubot = said.match(ASK_HUBOT_REGEX)
    if _ask_hubot
      said = _ask_hubot[1].trim()

    # Store message in cache
    messageCache = robot.brain.data.markov.messageCache
    messageCache.push({user: lcUserName, said: said.trim()})

    # Limit size of messageCache
    messageCacheLength = messageCache.length
    if messageCacheLength > MAX_MESSAGE_CACHE_LENGTH
      messageCache.splice(0, messageCacheLength - MAX_MESSAGE_CACHE_LENGTH)

# Commands:
#   Holly start drinking game - starts the drinking game
#   Holly stop drinking game - in a controversial move, this stops the drinking game

_ = require 'underscore'

drink = 'DRINK! :beer: :cocktail:'

stimulus_response = {
  'try': 'TMO',
  ':robot_face:': '`++ TARGETING ++`',
  'kicking cannon': ':boom:',
  'scrum': 'Not straight',
  'bonus point': 'Bullshit point, more like.',
  'ref cam': drink,
  'refcam': drink,
  'TMO': drink,
  'prop score': 'FINISH YOUR ' + drink,
  'forward score': drink,
  'fat man running with the ball': drink,
  'adverts': ':mute:',
}

teams = [
  ':eng:',
  ':fra:',
  ':ire:',
  ':ita:',
  ':scot:',
  ':wal:',
]

reset_score = ->
  scores = {}
  for team in teams
    scores[team] = 0
  return scores

whos_winning = (scores)->
  team_scores = []
  for team, score of scores
    team_scores.push({ 'team': team, 'score': score, })
  team_scores = _.sortBy(team_scores, 'score')
  team_scores.reverse()
  if team_scores[0].score == 0
    return "Nobody's scored yet."
  if team_scores[0].score > team_scores[1].score
    return team_scores[0].team + ' are beating ' + team_scores[1].team + ' ' + team_scores[0].score + '-' + team_scores[1].score
  else
    return "It's " + team_scores[0].score + ' each for ' + team_scores[0].team + ' and ' + team_scores[1].team


module.exports = (robot) ->

  robot.brain.on 'loaded', =>
    robot.brain.data.are_we_playing ||= false
    robot.brain.data.scores ||= reset_score()

  robot.respond /start drinking game/i, (msg) ->
    if robot.brain.data.are_we_playing
      msg.send "We're already playing a drinking game you smeg head!"
      return
    robot.brain.data.are_we_playing = true
    robot.brain.data.scores = reset_score()
    msg.send 'Hold on to your hats, dudes - we are having a drinking game.'

  robot.respond /stop drinking game/i, (msg) ->
    if not robot.brain.data.are_we_playing
      msg.send "We're not playing a drinking game you smeg head!"
      return
    robot.brain.data.are_we_playing = false
    msg.send "Well, that was fun but we're out of booze now.  Dog milk anyone?"

  robot.respond /who\'s winning/i, (msg) ->
    if robot.brain.data.are_we_playing
      msg.send(whos_winning(robot.brain.data.scores))

  robot.respond /what\'s the score/i, (msg) ->
    if robot.brain.data.are_we_playing
      msg.send(whos_winning(robot.brain.data.scores))

  robot.hear /(.*)/i, (msg) ->
    if robot.brain.data.are_we_playing
      message_text = msg.match[1]

      for word in message_text.split(' ')
        for team in teams
          if word.search(team) > -1
            robot.brain.data.scores[team] += 1

      for stimulus, response of stimulus_response
        regex = new RegExp(stimulus, 'i')
        match = regex.test(message_text)
        if match
          msg.send(response)
          return


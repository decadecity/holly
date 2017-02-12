# Commands:
#   Holly start drinking game - starts the drinking game
#   Holly stop drinking game - in a controversial move, this stops the drinking game

drink = 'DRINK! :beer: :cocktail:'

stimulus_response = {
  'try': 'TMO',
  ':robot:': '`++ TARGETING ++`',
  'kicking cannon': ':boom:',
  'scrum': 'Not straight',
  'ref cam': drink,
  'TMO': drink,
}

module.exports = (robot) ->

  robot.brain.on 'loaded', =>
    robot.brain.data.are_we_playing ||= false

  robot.respond /start drinking game/i, (msg) ->
    if robot.brain.data.are_we_playing
      msg.send "We're already playing a drinking game you smeg head!"
      return
    robot.brain.data.are_we_playing = true
    msg.send 'Hold on to your hats, dudes - we are having a drinking game.'

  robot.respond /stop drinking game/i, (msg) ->
    if not robot.brain.data.are_we_playing
      msg.send "We're not playing a drinking game you smeg head!"
      return
    robot.brain.data.are_we_playing = false
    msg.send "Well, that was fun but we're out of booze now.  Dog milk anyone?"

  robot.hear /(.*)/i, (msg) ->
    if robot.brain.data.are_we_playing
      message_text = msg.match[1]
      for stimulus, response of stimulus_response
        regex = new RegExp(stimulus, 'i')
        match = regex.test(message_text)
        if match
          msg.send(response)
          return

# Commands:
#   Holly when I say <call> you say <response>

call = null
response = null
debounce = false

module.exports = (robot) ->

  robot.brain.on 'loaded', =>
    robot.brain.data.callback ||= {}
    robot.brain.data.callback.call ||= null
    robot.brain.data.callback.response ||= null


  robot.respond /when i say ([\w .\-_]+) you say ([\w .\-_]+)[.!]*$/i, (msg) ->
    call = msg.match[1].trim()
    response = msg.match[2].trim()
    robot.brain.data.callback.call = call
    robot.brain.data.callback.response = response
    msg.send "Ok, when you say #{call} I say #{response}."
    debounce = true


  robot.hear /(.*)/i, (msg) ->
    if debounce
      debounce = false
      return
    said = msg.match[1]
    if call and response
      call_regex = new RegExp('\\b' + call + '\\b', 'i')
      if said.match(call_regex)
        msg.reply response


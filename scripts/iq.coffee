# Commands:
#   Holly what's your IQ? - tells you the current IQ

module.exports = (robot) ->

  robot.brain.on 'loaded', =>
    robot.brain.data.iq ||= {}
    robot.brain.data.iq.current = 6000
    robot.brain.data.iq.time = new Date().getTime()

  robot.respond /(.*)your iq(.*)/i, (msg) ->
    iq = robot.brain.data.iq.current
    time = robot.brain.data.iq.time
    delta = new Date().getTime() - time

    fudge = delta / (1000 * 60)
    fudge = fudge * Math.random()
    new_iq = Math.round(iq - fudge)

    robot.brain.data.iq.current = new_iq
    robot.brain.data.iq.time = new Date().getTime()

    msg.send "I have an IQ of " + new_iq

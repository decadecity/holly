module.exports = (robot) ->

  robot.hear /queeg/i, (msg) ->
    name = msg.message.user.name + "'"
    if name.match(/s'$/i) is null
      name = name + "s"
    msg.send "http://meh.yellowgrey.com/queeg.jpeg?_=" + Math.random()
    msg.send "Geekend is now run by Queeg 500!"
    msg.send "The company is paying for " + name + " hologrammatical survival, and out here in space I am the company!"
    setTimeout ( ->
      msg.send "We are talking jape of the decade. We are talking April, May, June, July and August fool. That's right. I am Queeg."
    ), 10000

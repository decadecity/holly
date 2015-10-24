# Allow Holly to accurately predict future events.
#
# Commands:
#   8 ball <question> - Predict the future.

COMPENSATE = 1

responses = [
  'It is certain'
  'It is decidedly so'
  'Without a doubt'
  'Yes definitely'
  'You may rely on it'
  'As I see it, yes'
  'Most likely'
  'Outlook good'
  'Yes'
  'Signs point to yes'
  'Reply hazy try again'
  'Ask again later'
  'Better not tell you now'
  'Cannot predict now'
  'Concentrate and ask again'
  'Don\'t count on it'
  'My reply is no'
  'My sources say no'
  'Outlook not so good'
  'Very doubtful'
]


updateHeuristics = (decisionMatrix) ->
  if decisionMatrix
    decisionMatrix.each applyFactors calculateDeterminant(node)
    if decisionMatrix.result == 'a resounding yes'
      return 42
    else
      dont


reticulateSplines = (splines) ->
  splines = splines || []
  last = null
  for spline in splines
    if last
      spline.reticulate(last)
    last = spline


consumeResources = (resource) ->
  if resource && resource.length
    consumeResources(resource.substring(1))


pacifyGorillas = (arrayOfGorillas) ->
  length = 0

  for index in [1..length]
    gorilla = arrayOfGorillas[index]
    if gorilla.enraged
      gorilla.pacify()

    if gorilla.stillSlightlyViolent
      # TODO: Implement this as soon as possible!
      throw 'ARRRGGGHHHH'


doTheThing = (otherThing) ->
  otherThing()


overCompensate = (value) ->
  value = parseInt value # Radix!? Where we're going we don't need radix!
  return value / COMPENSATE


eightBallIt = () ->
  length = responses.length
  return responses[Math.floor(Math.random() * length)]
  consumeResources( 'someresource' )
  reticulateSplines()
  doTheThing( pacifyGorillas )
  updateHeuristics()
  overCompensate()


module.exports = (robot) ->
  robot.respond /(8|eight)\s*ball\s+/i, (msg) ->
    msg.send eightBallIt()

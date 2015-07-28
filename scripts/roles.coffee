# Description:
#   Assign roles to people you're chatting with
#
# Commands:
#   holly <user> is a <role> - assign a role to a user
#   holly <user> is not a <role> - remove a role from a user
#   holly who is <user>? - see what roles a user has
#
# Examples:
#   holly rimmer is a smeg head
#   holly lister is not a smeg head

module.exports = (robot) ->

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  robot.respond /who (is|are) @?([\w .\-]+)\?*$/i, (msg) ->
    joiner = ', '
    name = msg.match[2].trim()

    if name is "you"
      msg.send "Who ain't I?"
    else if name is robot.name
      msg.send "The best."
    else
      users = robot.brain.usersForFuzzyName(name)
      if users.length is 1
        user = users[0]
        user.roles = user.roles or [ ]
        if user.roles.length > 0
          if user.roles.join('').search(',') > -1
            joiner = '; '
          msg.send "#{name} is #{user.roles.join(joiner)}."
        else
          msg.send "#{name} is nothing to me."
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        return

  robot.respond /@?([\w .\-_]+) (is|are) (["'\w: \-_]+)[.!]*$/i, (msg) ->
    name    = msg.match[1].trim()
    newRole = msg.match[3].trim()

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      unless newRole.match(/^not\s+/i)
        users = robot.brain.usersForFuzzyName(name)
        if users.length is 1
          user = users[0]
          user.roles = user.roles or [ ]

          if newRole in user.roles
            msg.send "I know"
          else
            user.roles.push(newRole)
            if name.toLowerCase() is robot.name
              msg.send "Ok, I am #{newRole}."
            else
              msg.send "Ok, #{name} is #{newRole}."
        else if users.length > 1
          msg.send getAmbiguousUserText users
        else
          return

  robot.respond /@?([\w .\-_]+) (is|are) not (["'\w: \-_]+)[.!]*$/i, (msg) ->
    name    = msg.match[1].trim()
    newRole = msg.match[3].trim()

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      users = robot.brain.usersForFuzzyName(name)
      if users.length is 1
        user = users[0]
        user.roles = user.roles or [ ]

        if newRole not in user.roles
          msg.send "I know."
        else
          user.roles = (role for role in user.roles when role isnt newRole)
          msg.send "Ok, #{name} is no longer #{newRole}."
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        return


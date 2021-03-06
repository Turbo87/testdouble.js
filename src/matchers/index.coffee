_ = require('lodash')
create = require('./create')
stringifyArguments = require('../stringify/arguments')

module.exports =
  create: create
  captor: require('./captor')

  isA: create
    name: (matcherArgs) ->
      s = if matcherArgs[0]?.name?
          matcherArgs[0].name
        else
          stringifyArguments(matcherArgs)
      "isA(#{s})"
    matches: (matcherArgs, actual) ->
      type = matcherArgs[0]

      if type == Number
        _.isNumber(actual)
      else if type == String
        _.isString(actual)
      else if type == Boolean
        _.isBoolean(actual)
      else
        actual instanceof type

  anything: create
    name: 'anything'
    matches: -> true

  contains: create
    name: 'contains'
    matches: (containings, actualArg) ->
      containsAllSpecified = (containing, actual) ->
        _.all containing, (val, key) ->
          return false unless actual?
          if _.isPlainObject(val)
            containsAllSpecified(val, actual[key])
          else
            _.eq(val, actual[key])

      _.all containings, (containing) ->
        if _.isString(containing)
          _.include(actualArg, containing)
        else if _.isArray(containing)
          _.any actualArg, (actualElement) ->
            _.eq(actualElement, containing)
        else if _.isPlainObject(containing)
          containsAllSpecified(containing, actualArg)
        else
          throw new Error("the contains() matcher only supports strings, arrays, and plain objects")

  argThat: create
    name: 'argThat'
    matches: (matcherArgs, actual) ->
      predicate = matcherArgs[0]
      predicate(actual)

  not: create
    name: 'not'
    matches: (matcherArgs, actual) ->
      expected = matcherArgs[0]
      !_.eq(expected, actual)

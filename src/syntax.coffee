trait = require 'escomplex-traits'
util = require './util'
getChildren = util.getChildren
call = require './call'


syntax = {
  Block: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Assign: {
    trait: ->
      trait.actualise 0, 0, undefined, undefined, getChildren, (node) -> util.getFullName(node.variable)
  },
  Value: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Literal: {
    trait: ->
      getOp = (node) -> return node.value

      trait.actualise(0, 0, undefined, getOp, getChildren)
  },
  Access: {
    trait: ->
      trait.actualise(1, 0, '.', undefined, getChildren)
  },
  Call: {
    trait: ->
      handleDeps = (node, clearAliases) ->
        call.amdPathAliases = {} if clearAliases

        if util.getName(node.variable) == "Value" and
        node.variable.properties.length == 0 and
        util.getName(node.variable.base) == "Literal" and
        node.variable.base.value == "require"
          return call.processRequire(node)

        if util.getName(node.variable) == "Value" and
        node.variable.properties.length == 1 and
        util.getName(node.variable.base) == "Literal" and
        node.variable.base.value == "require" and
        util.getName(node.variable.properties[0]) == "Access" and
        util.getName(node.variable.properties[0].name) == "Literal" and
        node.variable.properties[0].name.value == "config"
          call.processAmdRequireConfig(node.args)


      trait.actualise(1, 0, '()', undefined, getChildren, undefined, undefined, handleDeps)
  },
  Code: {
    # function declratation
    trait: ->
      trait.actualise(1, 0, 'function', '<anonymous>', getChildren, undefined, true)
  },
  Param: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Bool: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  For: {
    trait: (settings) ->
      complexity = (node) ->
        score = 0
        score++ if node.guard
        score++ if settings.forin

        return score

      trait.actualise(1, complexity, 'for', undefined, getChildren)
  },
  Index: {
    trait: ->
      trait.actualise(1, 0, '[]', undefined, getChildren)
  },
  If: {
    trait: ->
      calcLoc = (node) -> if node.alternate then 2 else 1
      ops = [
        'if',
        {identifier: 'else', filter: (node) -> !!node.alternate}
      ]
      trait.actualise(calcLoc, 1, ops, undefined, getChildren)
  },
  Op: {
    trait: ->
      getOp = (node) -> node.operator
      trait.actualise(0, 0, getOp, undefined, getChildren)
  },
  Return: {
    trait: ->
      trait.actualise(1, 0, 'return', undefined, getChildren)
  },
  Parens: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Obj: {
    trait: ->
      trait.actualise(0, 0, '{}', undefined, getChildren)
  },
  Arr: {
    trait: ->
      trait.actualise(0, 0, '[]', undefined, getChildren)
  },
  Undefined: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Null: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Splat: {
    trait: ->
      trait.actualise(0, 0, undefined, undefined, getChildren)
  },
  Class: {
    trait: ->
      trait.actualise(0, 0, 'class', undefined, getChildren)
  },
  Slice: {
    trait: ->
      trait.actualise(0, 0, '[]', undefined, getChildren)
  },
  Range: {
    trait: ->
      trait.actualise(0, 0, '[]', undefined, getChildren)
  },
  Existence: {
    trait: ->
      trait.actualise(0, 0, '!', undefined, getChildren)
  },
  In: {
    trait: ->
      trait.actualise(0, 0, 'in', undefined, getChildren)
  },
  While: {
    trait: ->
      hasCondition = (node) ->
        comp = 0
        comp++ if node.condition
        comp++ if node.guard
        comp

      trait.actualise(1, hasCondition, 'while', undefined, getChildren)
  },
  Extends: {
    trait: ->
      trait.actualise(0, 0, 'extends', undefined, getChildren)
  },
  Switch: {
    trait: (settings) ->
      getCases = (node) ->
        if !settings.switchcase
          return 0

        cases = node.cases.length
        cases++ if node.otherwise
        return cases

      trait.actualise(1, getCases, 'switch', undefined, getChildren)
  },
  Throw: {
    trait: ->
      trait.actualise(1, 0, 'throw', undefined, getChildren)
  },
  Try: {
    trait: (settings) ->
      haveRecovery = (node) ->
        if !settings.trycatch
          return 0

        if node.recovery then return 1 else return 0

      trait.actualise(1, haveRecovery, undefined, undefined, getChildren)
  },
}

setupSyntax = (settings) ->
  syntaxes = {}
  for name, obj of syntax
    syntaxes[name] = obj.trait(settings)

  syntaxes

module.exports = setupSyntax

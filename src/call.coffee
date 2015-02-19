{getName} = require "./util"

amdPathAliases = {}

createDependency = (node, path, type) ->
  {
    line: node.locationData.first_line
    path: path
    type: type
  }

resolveRequireDependency = (dependency, resolver) ->
  if getName(dependency) == 'Value' and getName(dependency.base) == 'Literal'
    return resolver(dependency.base.value) if typeof resolver == 'function'
    return dependency.base.value

  return '* dynamic dependency *'

resolveAmdRequireDependency = (dependency) ->
  amdPathAliases[dependency] or dependency

processAmdRequireItem = (node, item) ->
  createDependency node, resolveRequireDependency(item, resolveAmdRequireDependency), 'AMD'

processAmdRequire = (node) ->
  if getName(node.args[0]) == 'Value' and getName(node.args[0].base) == "Arr"
    return node.args[0].base.objects.map(processAmdRequireItem.bind(null, node))

  if getName(node.args[0]) == 'Value' and getName(node.args[0].base) == "Literal"
    return processAmdRequireItem(node, node.args[0])

  createDependency node, '* dynamic dependencies *', 'AMD'


processCommonJSRequire = (node) ->
  createDependency(node, resolveRequireDependency(node.args[0]), 'CommonJS')


setAmdPathAlias = (alias) ->
  if getName(alias.variable) == 'Value' and
  getName(alias.variable.base)  == 'Literal' and
  getName(alias.value) == 'Value' and
  getName(alias.value.base) == 'Literal'
    amdPathAliases[alias.variable.base.value] = alias.value.base.value

  return

processAmdRequireConfigProperty = (property) ->
  if getName(property.variable) == 'Value' and
  getName(property.variable.base) == 'Literal' and
  property.variable.base.value == 'paths' and
  getName(property.value) == 'Value' and
  getName(property.value.base) == 'Obj'
    property.value.base.properties.forEach setAmdPathAlias

  return

processAmdRequireConfig = (args) ->
  if args.length == 1 and getName(args[0]) == 'Value' and getName(args[0].base) == 'Obj'
    args[0].base.properties.forEach processAmdRequireConfigProperty
  return

processRequire = (node) ->
  if node.args.length == 1
    processCommonJSRequire(node)

  if node.args.length == 2
    processAmdRequire(node)

module.exports = {
  amdPathAliases: amdPathAliases,
  processAmdRequireConfig: processAmdRequireConfig,
  processRequire: processRequire
}

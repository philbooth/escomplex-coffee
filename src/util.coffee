
getName = (node) -> node.constructor.name
getChildren = (node) -> node.children
safeName = (node, defName) ->
  if typeof node == 'string'
    return node

  if typeof node == 'object' and typeof node.value == 'string'
    return node.value

  return defName || '<anonymous>'

getFullName = (varNode) ->
  base = safeName(varNode.base)
  if varNode.properties.length
    names = [base].concat varNode.properties.filter((n) -> getName(n) == "Access").map (n) -> safeName(n.name)

    return names.join('.')
  else
    return base

assignName = (node, parent) ->
  if getName(parent) == "Assign"
    return getFullName(parent.variable)

  return '<anonymous>'

module.exports = {
  getName: getName,
  getChildren: getChildren,
  safeName: safeName,
  getFullName: getFullName,
  assignName: assignName
}

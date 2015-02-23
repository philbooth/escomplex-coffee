syntaxDefinitions = require "./syntax"
util = require "./util"

module.exports = {
  walk: (tree, settings, callbacks) ->
    syntaxes = syntaxDefinitions(settings)
    visitNode = (node, assignedName) ->
      if Array.isArray(node)
        node.forEach (n) -> visitNode(n, assignedName)
      else if typeof node == "object" and node
        syntax = syntaxes[util.getName(node)]
        return if !syntax
        callbacks.processNode(node, syntax)

        if syntax.newScope
          lines = {
            start: {
              line: node.locationData.first_line
            },
            end: {
              line: node.locationData.last_line
            }
          }
          callbacks.createScope(util.safeName(node, assignedName), lines, node.params.length)

        visitChildren(syntax, node)

        if syntax.newScope
          callbacks.popScope()

    visitChildren = (syntax, node) ->
      children = syntax.children[0](node)
      if Array.isArray(children)
        children.forEach (child) ->
          name = if typeof syntax.assignableName == 'function' then syntax.assignableName(node) else null
          visitNode(node[child], name)




    visitNode(tree)
}

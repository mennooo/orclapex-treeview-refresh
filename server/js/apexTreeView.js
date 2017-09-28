/* global apex $ */
window.mho = window.mho || {}
;(function (namespace) {
  function refresh (options) {
    var tree$ = options.da.affectedElements.find('.a-TreeView')
    var nodeAdapter = tree$.treeView('getNodeAdapter')
    var promise = apex.server.plugin(options.ajaxIdentifier, {
      pageItems: options.itemsToSubmit
    }, {
      loadingIndicator: tree$,
      loadingIndicatorPosition: 'centered'
    })

    var expandedNodes,
      selectedNodes

    promise.done(function (data) {
      nodeAdapter.data = data
      expandedNodes = tree$.find('.is-collapsible').toArray()
      selectedNodes = tree$.treeView('getSelection').toArray()

      expandedNodes = expandedNodes.map(function (node) {
        return '#' + $(node).attr('id')
      })
      selectedNodes = selectedNodes.map(function (node) {
        return '#' + $(node).parent().attr('id')
      })

      tree$.treeView('refresh')

      expandedNodes.forEach(function (node) {
        tree$.treeView('expand', $(node))
      })

      tree$.treeView('setSelection', $(selectedNodes.join(',')), true)

      tree$.trigger('apexafterrefresh')
      apex.da.resume(options.da.resumeCallback, false)
    })
  }

  namespace.apexTreeView = {
    refresh: refresh
  }
})(window.mho)

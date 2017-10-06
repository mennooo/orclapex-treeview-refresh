/* global apex $ */
window.mho = window.mho || {}
;(function (namespace) {
  // We need to extend the treeView widget to return the baseId
  $.widget('apex.treeView', $.apex.treeView, {
    mhoGetBaseId: function () {
      return this.baseId
    }
  })
  // Keep all tree configurations in memory, useful on creating a new instance
  var gConfigurations = []

  function refresh (options) {
    // Get the widget element
    var tree$ = options.da.affectedElements.find('.a-TreeView')
    // Get the config from memory, identified by regionId
    var config = gConfigurations[options.da.affectedElements.first().attr('id')]
    // Get new tree data
    var promise = apex.server.plugin(options.ajaxIdentifier, {
      pageItems: options.itemsToSubmit
    }, {
      loadingIndicator: tree$,
      loadingIndicatorPosition: 'centered'
    })

    var expandedNodes,
      selectedNodes
    // After AJAX, refresh tree
    promise.done(function (data) {
      // What to do when tree is empty after refresh
      if ($.isEmptyObject(data.data)) {
        tree$.trigger('apexafterrefresh')
        apex.da.resume(options.da.resumeCallback, false)
        tree$.treeView('destroy')
        return
      }

      // Create instance of tree if it does not exist
      if (tree$.length === 0) {
        apex.widget.tree.init(config.treeId, {}, data.data, config.treeAction, config.selectedNodeId, data.config.hasIdentity, data.config.rootAdded, config.hasTooltips, config.iconType)
        apex.da.resume(options.da.resumeCallback, false)
        return
      }

      // If tree still exists then refresh data
      var nodeAdapter = tree$.treeView('getNodeAdapter')

      nodeAdapter.data = data.data
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

  function addInitConfig (config) {
    gConfigurations[config.regionId.toString()] = config
  }

  namespace.apexTreeView = {
    refresh: refresh,
    addInitConfig: addInitConfig
  }
})(window.mho)

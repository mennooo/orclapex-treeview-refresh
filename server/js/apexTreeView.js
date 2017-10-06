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

    var selectedNodes,
      expandedNodesIds

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
      selectedNodes = tree$.treeView('getSelectedNodes')
      expandedNodesIds = tree$.treeView('getNodeAdapter').getExpandedNodeIds(tree$.treeView('mhoGetBaseId'))

      tree$.treeView('refresh')

      expandedNodesIds.forEach(function (id) {
        var node$ = tree$.treeView('find', {
          depth: -1,
          findAll: false,
          match: function (node) {
            return node.id === id
          }
        })
        tree$.treeView('expand', node$)
      })

      selectedNodes.map(function (node) {
        return tree$.treeView('find', {
          depth: -1,
          findAll: false,
          match: function (node) {
            return node.id === node.id
          }
        })
      })
      if (selectedNodes.length > 0) {
        tree$.treeView('setSelectedNodes', selectedNodes, true)
      }

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

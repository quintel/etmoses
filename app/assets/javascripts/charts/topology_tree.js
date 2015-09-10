var TopologyTree = (function(){
  var url, container;

  TopologyTree.prototype = {
    showTree: function() {
      $("#collapse-stakeholders select").prop('disabled', true);

      new Poller({
        url: url,
        hooks: {
          final_success: d3Callback
        }
      }).poll();
    }
  };

  function d3Callback(treeData){
    if (treeData.error) {
      new ErrorDisplayer(treeData.error, container).displayError();
    }
    else if(treeData.graph){
      $("#collapse-stakeholders select").prop('disabled', false);

      new TreeGraph(url, treeData.graph, container).showGraph();
    };
  };

  function TopologyTree(_url, _container){
    url = _url;
    container = _container;
  };

  return TopologyTree;
})();

var TopologyTreeHelper = {
  strategies: function(){
    var strategies = JSON.parse($(".strategies.hidden").text());
        strategies['capping_fraction'] = parseFloat($("#solar_pv_capping").val()) / 100;

    return { strategies: strategies };
  }
};

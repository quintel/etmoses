var TopologyTree = (function(){
  var url, container;

  TopologyTree.prototype = {
    showTree: function() {
      d3.json(url)
        .header("Content-Type", "application/json")
        .header("Accept", "application/json")
        .post(TopologyTreeHelper.strategies(), d3Callback);
    }
  };

  function d3Callback(error, treeData){
    if (error) {
      new ErrorDisplayer(error, container).displayError();
    }
    else{
      $("#collapse-stakeholders select").removeAttr("disabled");

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

    return JSON.stringify({ strategies: strategies });
  }
};

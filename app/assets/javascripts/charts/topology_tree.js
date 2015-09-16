var TopologyTree = (function(){
  var url, container;

  TopologyTree.prototype = {
    showTree: function() {
      $("#collapse-stakeholders select").prop('disabled', true);

      new Poller({ url: url }).poll().done(d3Callback).fail(failCallback);
    }
  };

  function d3Callback(treeData){
    $("#collapse-stakeholders select").prop('disabled', false);

    new TreeGraph(url, treeData.graph, container).showGraph();
  };

  function failCallback(treeData){
    new ErrorDisplayer(treeData.responseJSON, container).displayError();
  };

  function TopologyTree(_url, _container){
    url = _url;
    container = _container;
  };

  return TopologyTree;
})();

var TopologyTreeHelper = {
  strategies: function(){
    var strategies = JSON.parse($(".save_strategies.hidden").text());
        strategies['capping_fraction'] = parseFloat($("#solar_pv_capping").val()) / 100;

    return { strategies: strategies };
  }
};

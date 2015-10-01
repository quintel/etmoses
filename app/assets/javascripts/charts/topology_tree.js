var TopologyTree = (function(){
  var url, container, treeGraph;

  TopologyTree.prototype = {
    showTree: function() {
      $("a.dropdown-toggle").first().addClass("disabled");
      $("#collapse-stakeholders select").prop('disabled', true);

      treeGraph.strategyToggler.toggleLoading();
      treeGraph.strategyToggler.setStrategies();

      getTree({}, d3Callback);
      getTree({ strategies: StrategyHelper.getStrategies() }, updateLoadChart);
    }
  };

  function getTree(data, callback){
    new Poller({ url: url, data: data }).poll().done(callback).fail(failCallback);
  };

  function updateLoadChart(treeDataWithStrategies){
    treeGraph.strategyToggler.updateLoadChartWithStrategies(treeDataWithStrategies);
    treeGraph.initialStrategyCallDone = true;
    treeGraph.showGraph();
  };

  function d3Callback(treeData){
    $("#collapse-stakeholders select").prop('disabled', false);

    treeGraph.initialCallDone = true;
    treeGraph.showGraph(treeData.graph);
  };

  function failCallback(treeData){
    new ErrorDisplayer(treeData.responseJSON, container).displayError();
  };

  function TopologyTree(_url, _container){
    url       = _url;
    container = _container;
    treeGraph = new TreeGraph(url, container);
  };

  return TopologyTree;
})();


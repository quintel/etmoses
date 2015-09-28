var TopologyTree = (function(){
  var url, container, treeGraph;

  TopologyTree.prototype = {
    showTree: function() {
      $("#collapse-stakeholders select").prop('disabled', true);

      treeGraph.strategyToggler.toggleLoading();

      getTree({}, d3Callback);
      getTree({ strategies: StrategyHelper.getStrategies() }, updateLoadChart);
    }
  };

  function getTree(data, callback){
    new Poller({ url: url, data: data }).poll().done(callback).fail(failCallback);
  };

  function updateLoadChart(treeDataWithStrategies){
    console.log("2: ---- green line");
    console.log(treeDataWithStrategies.graph.children[0].children[0].children[0].load.slice(15025, 15045))
    treeGraph.strategyToggler.updateLoadChartWithStrategies(treeDataWithStrategies);
    treeGraph.initialStrategyCallDone = true;
    treeGraph.showGraph();
  };

  function d3Callback(treeData){
    console.log("1: ---- blue line");
    console.log(treeData.graph.children[0].children[0].children[0].load.slice(15025, 15045))
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


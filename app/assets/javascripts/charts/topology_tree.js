var TopologyTree = (function(){
  var url, container;

  TopologyTree.prototype = {
    showTree: function() {
      d3.json(url, d3Callback);
    }
  };

  function d3Callback(error, treeData){
    if (error) {
      new ErrorDisplayer(error, container).displayError();
    }
    else{
      new TreeGraph(url, treeData.graph, container).showGraph();
    };
  };

  function TopologyTree(_url, _container){
    url = _url;
    container = _container;
  };

  return TopologyTree;
})();

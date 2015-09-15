var TopologyTree = (function(){
  var urls, finishUrl, container;

  TopologyTree.prototype = {
    showTree: function() {
      $("#collapse-stakeholders select").prop('disabled', true);

      new Poller({ url: url }).poll().done(displayData);
    }
  };

  function displayData(){
    $.ajax({
      type:         "POST",
      contentType:  "application/json",
      dataType:     "json",
      url:          finishUrl,
      success:      d3Callback
    });
  };

  function d3Callback(treeData){
    if (treeData.error) {
      new ErrorDisplayer(treeData.error, container).displayError();
    }
    else if(treeData.graph){
      $("#collapse-stakeholders select").prop('disabled', false);

      new TreeGraph(url, finishUrl, treeData.graph, container).showGraph();
    };
  };

  function TopologyTree(_urls, _container){
    url = _urls.url;
    finishUrl = _urls.finishUrl;
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

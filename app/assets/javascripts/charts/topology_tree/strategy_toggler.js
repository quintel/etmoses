var StrategyToggler = (function(){
  var loadChart, applyStrategyButton;
  var clearStrategies = false;

  StrategyToggler.prototype = {
    addOnChangeListener: function(){
      applyStrategyButton = $("button.apply_strategies");
      applyStrategyButton.prop('disabled', false);
      applyStrategyButton.on("click", this.applyStrategies.bind(this));
    },

    applyStrategies: function(){
      updateStrategies();
      setClearStrategies();
      toggleStrategies();
    }
  };

  function getStrategies(){
    return JSON.parse($(".strategies.hidden").text());
  };

  function updateStrategies(){
    var appliedStrategies = getStrategies();
    $(".load-strategies input[type=checkbox]").each(function(){
      appliedStrategies[$(this).val()] = $(this).is(":checked");
    })
    $(".strategies.hidden").text(JSON.stringify(appliedStrategies));
  };

  function setClearStrategies(){
    clearStrategies = true;
    $(".load-strategies input[type=checkbox]").each(function(){
      if($(this).is(":checked")){
        clearStrategies = false;
        return false;
      }
    });
  };

  function toggleStrategies(){
    toggleLoading();
    loadChart.strategyShown = true;

    if (loadChart.strategyLoads === true) {
      return false;
    }
    else {
      loadChart.strategyLoads = true;

      d3.json(loadChart.url)
        .header("Content-Type", "application/json")
        .header("Accept", "application/json")
        .post(TopologyTreeHelper.strategies(), updateLoadChart);
    }
  };

  function updateLoadChart(error, strategyData){
    toggleLoading();

    loadChart.strategyLoads = {};

    ETHelper.eachNode([strategyData.graph], function(node) {
      loadChart.strategyLoads[node.name] = node.load;
    });

    ETHelper.eachNode([loadChart.root], function(node) {
      if(clearStrategies){
        loadChart.strategyShown = false;
        delete node.altLoad;
      }
      else{
        node.altLoad = loadChart.strategyLoads[node.name];
      }
    });

    LoadChartHelper.forceReload = true

    loadChart.showChart(loadChart.lastClicked);
    loadChart.update(loadChart.root);
  };

  function toggleLoading(){
    var loadingSpinner = $(".loading-spinner");
    loadingSpinner.toggleClass("on");
    applyStrategyButton.prop("disabled", loadingSpinner.hasClass("on"));
  };

  function StrategyToggler(_loadChart){
    loadChart = _loadChart;
  };

  return StrategyToggler;
})();

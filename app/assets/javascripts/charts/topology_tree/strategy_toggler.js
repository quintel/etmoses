var StrategyToggler = (function(){
  var loadChart, applyStrategyButton, businessCaseTable;
  var clearStrategies = false;
  var shouldPollBusinessCase = true;

  StrategyToggler.prototype = {
    addOnChangeListener: function(){
      applyStrategyButton = $("button.apply_strategies");
      applyStrategyButton.prop('disabled', false);
      applyStrategyButton.on("click", this.applyStrategies.bind(this));
    },

    applyStrategies: function(){
      shouldPollBusinessCase = true;

      updateStrategies();
      setClearStrategies();
      toggleStrategies();
    },

    setDefaultStrategies: function(){
      shouldPollBusinessCase = false;

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

      pollTree();
      if(shouldPollBusinessCase){
        pollBusinessCase();
      };
    }
  };

  function pollTree(){
    new Poller({
      url: loadChart.url,
      data: TopologyTreeHelper.strategies(),
      hooks: {
        final_success: updateLoadChart
      }
    }).poll();
  };

  function pollBusinessCase(){
    new Poller({
      url: businessCaseTable.data('url'),
      data: TopologyTreeHelper.strategies(),
      first_data: { clear: true },
      hooks: {
        final_success: renderSummary,
        pending: showLoadingSpinner
      }
    }).poll();
  };

  function renderSummary(){
    $.ajax({ type: "POST", url: businessCaseTable.data('finishUrl') });
    $("#business_case_table .loading-spinner").removeClass("on");
    $("select#compare").prop('disabled', false);
  };

  function showLoadingSpinner(){
    $("#business_case_table .loading-spinner").addClass("on");
    $("select#compare").prop('disabled', true);
  };

  function updateLoadChart(strategyData){
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
    var loadingSpinner = $(".load-graph-wrapper .loading-spinner");
    loadingSpinner.toggleClass("on");
    applyStrategyButton.prop("disabled", loadingSpinner.hasClass("on"));
  };

  function StrategyToggler(_loadChart){
    loadChart = _loadChart;
    businessCaseTable = $("#business_case_table");
  };

  return StrategyToggler;
})();

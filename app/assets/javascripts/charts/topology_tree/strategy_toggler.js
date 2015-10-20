var StrategyToggler = (function(){
  var loadChart, applyStrategyButton, businessCaseTable, savedStrategies;
  var sliderSettings = {
    focus: true,
    formatter: function(value){
      return value + "%";
    }
  };

  var multiSelectSettings = {
    buttonText: function(options) {
      var text = 'Customise technology behaviour';

      if (options.length) {
        text = text + ' (' + options.length + ' selected)';
      }

      return text;
    },
    dropRight: true
  };

  StrategyToggler.prototype = {
    addOnChangeListener: function(){
      applyStrategyButton.prop('disabled', false);
      applyStrategyButton.on("click", this.applyStrategies.bind(this));
    },

    applyStrategies: function(){
      updateStrategies.call(this);
      storeStrategies.call(this);
      toggleStrategies.call(this);
    },

    toggleLoading: function(){
      var loadingSpinner = $(".load-graph-wrapper .loading-spinner");
          loadingSpinner.toggleClass("on");

      applyStrategyButton.prop("disabled", loadingSpinner.hasClass("on"));
    },

    updateLoadChartWithStrategies: function(data){
      updateLoadChart.call(this, data);
    },

    setStrategies: function(){
      savedStrategies = JSON.parse($(".save_strategies").text());

      var multiSelect = buildMultiSelect();
          multiSelect.multiselect('select', getSelectedItems());

      var cappingInput = $("input[type=checkbox][value=capping_solar_pv]")
          cappingInput.parents('a').append($(".slider-wrapper.hidden"));
          cappingInput.on("change", showSlider);

      showSlider.call(cappingInput);

      $("#solar_pv_capping").slider(sliderSettings)
        .slider('setValue', (savedStrategies.capping_fraction || 1) * 100);
    },

    clear: function(){
      var clearStrategies = true;
      $(".load-strategies input[type=checkbox]").each(function(){
        if($(this).is(":checked")){
          clearStrategies = false;
        };
      });
      return clearStrategies;
    }
  };

  function showSlider(){
    var sliderWrapper = $(this).parents('a').find(".slider-wrapper");

    sliderWrapper.toggleClass("hidden", ! $(this).is(":checked"));
  };

  function buildMultiSelect(){
    var multiSelect = $("select.multi-select")
        multiSelect.multiselect(multiSelectSettings);

    return multiSelect;
  };

  function getSelectedItems(){
    var selected = [];
    for(var strategy in savedStrategies){
      if(savedStrategies[strategy]){
        selected.push(strategy);
      };
    };
    return selected;
  };

  function storeStrategies(){
    if(applyStrategyButton.data('isAllowedToStoreStrategies')){
      $.ajax({
        type: "POST",
        url:  applyStrategyButton.data('url'),
        data: {
          strategies: StrategyHelper.getStrategies()
        }
      });
    };
  };

  function updateStrategies(){
    var appliedStrategies = StrategyHelper.getStrategies();
    $(".load-strategies input[type=checkbox]").each(function(){
      appliedStrategies[$(this).val()] = $(this).is(":checked");
    })
    $(".save_strategies.hidden").text(JSON.stringify(appliedStrategies));
  };

  function toggleStrategies(){
    this.toggleLoading();
    loadChart.strategyShown = true;

    if (loadChart.strategyLoads === true) {
      return false;
    }
    else {
      loadChart.strategyLoads = true;

      pollTree.call(this);
      pollBusinessCase.call(this);
    }
  };

  function pollTree(){
    new Poller({
      url: loadChart.url,
      data: { strategies: StrategyHelper.getStrategies() }
    }).poll().done(updateLoadChart.bind(this));
  };

  function pollBusinessCase(){
    new Poller({
      url: businessCaseTable.data('url'),
      data: { strategies: StrategyHelper.getStrategies() },
      first_data: { clear: true }
    }).poll().done(renderSummary).progress(showLoadingSpinner);
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
    this.toggleLoading();

    loadChart.applyStrategies(strategyData);
  };

  function StrategyToggler(_loadChart){
    loadChart           = _loadChart;
    businessCaseTable   = $("#business_case_table");
    applyStrategyButton = $("button.apply_strategies");
  };

  return StrategyToggler;
})();

var StrategyHelper = {
  getStrategies: function(){
    var strategies = JSON.parse($(".save_strategies.hidden").text());
        strategies['capping_fraction'] = parseFloat($("#solar_pv_capping").val()) / 100;

    return strategies;
  }
};

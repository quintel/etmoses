var StrategyHelper = {
  getStrategies: function(){
    var strategies = JSON.parse($(".save_strategies.hidden").text());
        strategies['capping_fraction'] = parseFloat($("#solar_pv_capping").val()) / 100;

    return strategies;
  },

  anyStrategies: function(){
    var strategies = StrategyHelper.getStrategies();
    var anyStrategy = false;

    for(var key in strategies){
      if(strategies[key] && key != 'capping_fraction'){
        anyStrategy = true;
        break;
      }
    };

    return anyStrategy;
  }
};


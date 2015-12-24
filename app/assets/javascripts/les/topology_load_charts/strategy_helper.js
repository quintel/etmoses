var StrategyHelper = {
    getStrategies: function () {
        'use strict';

        var strategies = JSON.parse($(".save_strategies.hidden").text());
        strategies.capping_fraction = parseFloat($("#solar_pv_capping").val()) / 100;

        return strategies;
    },

    anyStrategies: function () {
        'use strict';

        var key,
            strategies = StrategyHelper.getStrategies(),
            anyStrategy = false;

        for (key in strategies) {
            if (strategies[key] && key !== 'capping_fraction') {
                anyStrategy = true;
                break;
            }
        }

        return anyStrategy;
    }
};

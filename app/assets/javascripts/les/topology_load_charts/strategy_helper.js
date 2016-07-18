var StrategyHelper = {
    getStrategies: function () {
        'use strict';


        var strategies = JSON.parse($(".save_strategies.hidden").text()),
            cappingFraction = $("#solar_pv_capping").val();

        if (cappingFraction) {
            // If a cappingFraction slider is present, take the value from that,
            // otherwise the original value provided in the JSON will do.
            strategies.capping_fraction = parseFloat(cappingFraction) / 100;
        }

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

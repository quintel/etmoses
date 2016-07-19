var StrategyHelper = {
    getStrategies: function () {
        'use strict';

        return JSON.parse($(".save_strategies.hidden").text());
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

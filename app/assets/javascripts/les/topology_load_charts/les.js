/*globals StrategyHelper*/
var Les = (function () {
    'use strict';

    Les.prototype = {
        data: { calculation: {} },
        nodeData: function (lesOptions) {
            $.extend(this.data.calculation, lesOptions);

            this.data.type = ($.isEmptyObject(this.strategies) ? 'basic' :  'features');

            if (this.data.calculation.resolution === 'high') {
                this.data.calculation.nodes = window.currentTree.nodes;
            }

            if (this.strategies) {
                this.data.calculation.strategies = StrategyHelper.getStrategies();
            } else {
                delete this.data.calculation.strategies;
            }

            return this.data;
        },

        anyStrategies: function () {
            return (this.strategies === undefined ||
                    (this.strategies && StrategyHelper.anyStrategies()));
        }
    };

    function Les(strategies) {
        this.strategies = strategies;
    }

    return Les;
}());

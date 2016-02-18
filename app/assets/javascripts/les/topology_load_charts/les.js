/*globals StrategyHelper*/
var Les = (function () {
    'use strict';

    Les.prototype = {
        data: { calculation: {} },
        nodeData: function (resolution) {
            this.data.type = ($.isEmptyObject(this.strategies) ? 'basic' :  'features');

            if (resolution) {
                this.data.calculation.resolution = resolution;
            }

            if (resolution === 'high') {
                this.data.calculation.nodes = window.currentTree.nodes;
            }

            if (this.strategies) {
                this.data.calculation.strategies = StrategyHelper.getStrategies();
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

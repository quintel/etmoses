var LoadChartInterface = (function () {
    'use strict';

    return {
        update: function () {
            var viewAs         = $("select.chart-view[name='view_as']"),
                viewCarrier    = $("select.chart-view[name='view_carrier']"),
                viewStrategies = $(".chart-view[name='strategies']"),
                isTotal        = (viewAs.val() === 'total'),
                showViewAs     = !window.currentTree.basicCharts.some(function (chartType) {
                                      return this[chartType] &&
                                             this[chartType].tech_loads;
                                  }.bind(this));

            viewAs.prop('disabled', showViewAs);

            viewCarrier
                .prop('disabled', isTotal)
                .toggle(!isTotal);

            viewStrategies
                .parent()
                .toggle(!isTotal && StrategyHelper.anyStrategies());
        }
    };
}());

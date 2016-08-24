var LoadChartInterface = (function () {
    'use strict';

    return {
        update: function () {
            var viewAs         = $("select.chart-view[name='view_as']"),
                viewCarrier    = $("select.chart-view[name='view_carrier']"),
                viewStrategies = $(".chart-view[name='strategies']"),
                isTotal        = (viewAs.val() === 'total'),
                showViewAs     = !((this.load && this.load.tech_loads) ||
                                   (this.gas  && this.gas.tech_loads) ||
                                   (this.heat && this.heat.tech_loads));

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

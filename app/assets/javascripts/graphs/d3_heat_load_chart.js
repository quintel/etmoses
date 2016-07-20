/*globals D3BaseStaticLoadChart*/

var D3HeatLoadChart = (function () {
    'use strict';

    D3HeatLoadChart.prototype = $.extend({}, D3BaseStaticLoadChart.prototype, {
        maxYvalue: function () {
            return d3.max(this.settings.load.map(function (loads) {
                return d3.max(loads.values.total);
            }));
        },
    });

    function D3HeatLoadChart(chartClass, settings) {
        D3BaseStaticLoadChart.call(this, chartClass, settings);
    }

    return D3HeatLoadChart;
}());

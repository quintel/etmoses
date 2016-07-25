/*globals D3BaseStaticLoadChart*/

var D3GasLoadChart = (function () {
    'use strict';

    D3GasLoadChart.prototype = $.extend({}, D3BaseStaticLoadChart.prototype, {
        maxYvalue: function (load) {
            return d3.max(load.values.map(function (loads) {
                return d3.max(loads.load);
            }));
        }
    });

    function D3GasLoadChart(chartClass, settings) {
        D3BaseStaticLoadChart.call(this, chartClass, settings);
    }

    return D3GasLoadChart;
}());

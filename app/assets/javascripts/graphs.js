/*globals D3LineGraph,D3StackedBarGraph*/

$(document).on('page:change', function () {
    'use strict';

    var defaults = {
            type: 'line',
            interpolate: 'linear'
        },
        graphs = {
            line: D3LineGraph,
            stacked_bar: D3StackedBarGraph,
            gas_load_chart: GasLoadChart
        };

    window.graphs = [];

    $(".graph").each(function () {
        var data  = $(this).data(),
            Graph = graphs[data.type || defaults.type];

        if (Graph) {
            window.graphs.push(
                new Graph(this, $.extend(defaults, data)).draw()
            );
        }
    });
});

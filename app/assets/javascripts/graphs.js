/*globals D3LineGraph,D3StackedBarGraph,StaticLoadChart*/

$(document).on('page:change', function () {
    'use strict';

    var defaults = {
            type: 'line',
            interpolate: 'linear'
        },
        graphs = {
            line:              D3LineGraph,
            stacked_bar:       D3StackedBarGraph,
            static_load_chart: StaticLoadChart
        };

    window.graphs = [];

    $(".graph").each(function () {
        var data  = $(this).underscorizedData(),
            Graph = graphs[data.type || defaults.type];

        if (Graph) {
            window.graphs.push(
                new Graph(this, $.extend(defaults, data)).draw()
            );
        }
    });
});

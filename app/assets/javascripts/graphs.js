/*globals D3LineGraph*/

$(document).on('page:change', function () {
    'use strict';

    var defaults = {
            type: 'line',
            interpolate: 'linear'
        },
        graphs = {
            line: D3LineGraph
        };

    $(".graph").each(function () {
        var data  = $(this).data(),
            Graph = graphs[data.type || defaults.type];

        if (Graph) {
            new Graph(this, $.extend(defaults, data)).append();
        }
    });
});

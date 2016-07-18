/*globals D3LineGraph,D3StackedBarGraph,StaticLoadChart*/

$(document).on('page:change', function () {
    'use strict';

    $(".graph").each(function () {
        new Graph(this).render();
    });

    $("button.render-area").off('click').on('click', function () {
        var graphId = $(this).parents(".graph").attr('id');

        $(this).attr('disabled', true);
        window.graphs[graphId].draw();
    });
});

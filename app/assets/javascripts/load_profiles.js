/*globals LoadChartPreview*/

$(document).on("page:change", function () {
    'use strict';

    $("li.category").on("click", function (e) {
        $(e.currentTarget).children("ul").slideToggle(200);
    });

    $("li.category").children().on("click", function (e) {
        e.stopPropagation();
    });

    if ($('.profile-graph').length > 0) {
        $(".profile-graph").each(function () {
            new LoadChartPreview(this).preview();
        });
    }
});

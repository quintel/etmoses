$(document).on("page:change", function () {
    'use strict';

    var stakeholderValue,
        currentClass;

    $("select#stakeholders").on("change", function () {
        stakeholderValue = $(this).val();

        d3.selectAll("g.node").attr("class", function (d) {
            currentClass    = d3.select(this).attr("class");
            d.node_selected = (new RegExp(stakeholderValue).test(currentClass) && stakeholderValue !== "");

            if (d.node_selected) {
                return currentClass + ' selected';
            } else {
                return currentClass.replace(/\sselected/, '');
            }
        });
    });
});

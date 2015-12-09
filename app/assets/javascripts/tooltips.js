$(document).on("page:change", function () {
    'use strict';

    $("body").tooltip({ selector: "a.tooltip-link", trigger: "click" });
    $("a.tooltip-link").on("click", function (e) {
        e.preventDefault();
    });
});

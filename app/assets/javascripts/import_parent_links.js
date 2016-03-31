$(document).on("page:change", function () {
    'use strict';

    function correctHref() {
        return !this.href.match(/import\#/);
    }

    if ($("#import-mark").length > 0) {
        $("a").filter(correctHref).attr("target", "_blank");
    }
});


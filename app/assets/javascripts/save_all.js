/*globals document*/
var SaveAll = (function () {
    'use strict';

    function finishAndRedirect() {
        this.saveAllButton.removeClass("disabled");

        window.location.replace(this.saveAllButton.data('url'));
    }

    function click(e) {
        e.preventDefault();

        this.completeCount = 0;
        this.saveAllButton.addClass("disabled");
        this.submitForms(finishAndRedirect);
    }

    function done(doneCallback) {
        this.completeCount += 1;

        if (this.completeCount === $(".remote form").length) {
            doneCallback.call(this);
        }
    }

    SaveAll.prototype = {
        append: function () {
            this.saveAllButton.off("click").on("click", click.bind(this));
        },

        submitForms: function (success) {
            $(".remote form").each(function (i, form) {
                $(form).submit();
                $(form).on("ajax:success", done.bind(this, success));
            }.bind(this));
        }
    };

    function SaveAll() {
        this.saveAllButton = $("a.btn.save-all");
        this.completeCount = 0;
    }

    return SaveAll;
}());

$(document).on("page:change", function () {
    'use strict';

    $(".tab-content .remote form").on("submit", function () {
        $(this).find("input[type=submit]").addClass("disabled");
        $(this).find("span.wait").removeClass("hidden");
    });

    $(".remote form").on("change", function () {
        var tabTarget = $(this).parent().attr("id"),
            tabHeader = $("ul.nav-tabs li a[href='#" + tabTarget + "']");

        tabHeader.addClass("editing");
    });

    window.saveAll = new SaveAll();
    window.saveAll.append();
});

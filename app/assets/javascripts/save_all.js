/*globals document*/
var SaveAll = (function () {
    'use strict';

    function finishAndRedirect() {
        this.saveAllButton.removeClass("disabled");

        window.location.replace(this.saveAllButton.data('url'));
    }

    function editedLes() {
        return $("ul.nav-tabs li a.editing").length > 0;
    }

    function click(e) {
        e.preventDefault();

        this.completeCount = 0;
        this.saveAllButton.addClass("disabled");

        if (editedLes()) {
            this.submitForms(finishAndRedirect.bind(this));
        } else {
            finishAndRedirect.call(this);
        }
    }

    function done(doneCallback) {
        this.completeCount += 1;

        if (this.completeCount === $(".remote form.editing").length) {
            doneCallback.call(this);
        }
    }

    SaveAll.prototype = {
        append: function () {
            this.saveAllButton.off("click").on("click", click.bind(this));
        },

        submitForms: function (success) {
            var self = this;
            $(".remote form.editing").each(function () {
                $(this).submit();
                $(this).on("ajax:success", done.bind(self, success));
            });
        }
    };

    function SaveAll(button) {
        this.saveAllButton = $(button);
        this.completeCount = 0;
    }

    return SaveAll;
}());

$(document).on("page:change", function () {
    'use strict';

    if ($(".remote form").length > 0) {
        $(".tab-content .remote form").on("submit", function () {
            $(this).find("input[type=submit]").addClass("disabled");
            $(this).find("span.wait").removeClass("hidden");
        });

        $(".remote form").on("change", function () {
            var tabTarget = $(this).parent().attr("id"),
                tabHeader = $("ul.nav-tabs li a[href='#" + tabTarget + "']");

            tabHeader.addClass("editing");
            $(this).addClass("editing");
        });

        $("a.save-all").each(function() {
            new SaveAll(this).append();
        });
    }
});

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

    function submit() {
        $(this).find("input[type=submit]").addClass("disabled");
        $(this).find("span.wait").removeClass("hidden");
    }

    function change(e) {
        var tabTarget = $(e.target).parents(".tab-pane").attr("id"),
            tabHeader = $("ul.nav-tabs li a[href='#" + tabTarget + "']");

        $(e.target).parents("form")
            .add(tabHeader)
            .addClass("editing");
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
            this.form
                .on("submit", submit.bind(this))
                .on("change.save_all", change.bind(this));
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
        this.form          = this.saveAllButton.parents("form");
        this.completeCount = 0;
    }

    return SaveAll;
}());

$(document).on("page:change", function () {
    'use strict';

    var saveAll = $("a.save-all");

    if (saveAll.length > 0) {
        saveAll.each(function() {
            new SaveAll(this).append();
        });
    }
});

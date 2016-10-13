/*globals CustomPrompt*/

var SaveAsForm = (function () {
    'use strict';

    function redirectToClonedLes(data) {
        window.location.replace(data.redirect);
    }

    function displayErrors(e, f) {
        var field,
            errors        = e.responseJSON.errors,
            errorField    = this.customPrompt.$content.find(".alert-danger"),
            messageHolder = $("<div>");

        errorField.removeClass("hidden").html('');

        for (field in errors) {
            errors[field].forEach(function (message) {
                messageHolder.text(field.toTitleCase() + " " + message);

                errorField.append(messageHolder);
            });
        };
    }

    function submitSaveAsForm() {
        $.ajax({
            url: this.formAction,
            type: "PATCH",
            data: {
                testing_ground: {
                    name: this.nameInput.val()
                }
            },
            success: redirectToClonedLes,
            error: displayErrors.bind(this)
        });
    }

    function onSaveAs(e) {
        e.preventDefault();

        if (this.nameInput.hasClass('changed')) {
            submitSaveAsForm.call(this);
        } else {
            this.customPrompt = CustomPrompt.prompt(
                "Please set a new name for your LES",
                this.nameInput.val(),
                submitSaveAsForm.bind(this)
            );
            this.nameInput = this.customPrompt.$content.find(".prompt-message");
        }
    }

    SaveAsForm.prototype = {
        initialize: function () {
            this.context
                .off("click.onSaveAs")
                .on("click.onSaveAs", onSaveAs.bind(this));

            this.nameInput.on('change.name', function () {
                this.nameInput.addClass('changed').off('change.name');
            }.bind(this));
        }
    };

    function SaveAsForm(context) {
        this.context    = context;
        this.nameInput  = $("input#testing_ground_name");
        this.formAction = this.context.data('url');
        this.form       = this.nameInput.parents("form");
    }

    return SaveAsForm;
}());

$(document).on('page:change', function () {
    'use strict';

    var saveAs = $(".save_as");

    if (saveAs.length > 0) {
        new SaveAsForm(saveAs).initialize();
    }
});

/*globals CustomPrompt*/

var SaveAsForm = (function () {
    'use strict';

    function redirectToClonedLes(data) {
        window.location.replace(data.redirect);
    }

    function displayErrors(e) {
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
        }
    }

    function submitSaveAsForm() {
        $.ajax({
            type:    "PATCH",
            url:     this.url,
            data:    this.data(),
            success: redirectToClonedLes,
            error:   displayErrors.bind(this)
        });
    }

    function onSaveAs(e) {
        e.preventDefault();

        if (this.nameInput.hasClass('changed')) {
            submitSaveAsForm.call(this);
        } else {
            this.customPrompt = CustomPrompt.prompt(
                this.promptText,
                this.nameInput.val(),
                submitSaveAsForm.bind(this)
            );

            // When there are no changes to the target save as input field
            // overwrite the input with the input from the popup. Please
            // consider that this is a rather hacky solution and any
            // better solution would be greatly appreciated.
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
        },

        data: function (scope) {
            var obj = {};

            obj[this.dataScope] = { name: this.nameInput.val() }

            return obj;
        }
    };

    function SaveAsForm(context) {
        this.context    = context;
        this.nameInput  = $("input.save-as-name");
        this.url        = this.context.data('url');
        this.dataScope  = this.context.data('scope');
        this.promptText = I18n.t("save_as_prompt." + this.dataScope);
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

/*globals document,customPrompt*/

$(document).on('page:change', function () {
    'use strict';

    var nameInput = $("input#testing_ground_name");

    function submitSaveAsForm() {
        var form = $(this).parents("form");
        form.attr("action", $(this).data('url'));
        form.submit();
    }

    function promptCallback(newName) {
        nameInput.val(newName);

        submitSaveAsForm.call(this);
    }

    function onSaveAs(e) {
        e.preventDefault();

        if (nameInput.hasClass('changed')) {
            submitSaveAsForm.call(this);
        } else {
            customPrompt(
                "Please set a name for your new LES",
                nameInput.val(),
                promptCallback.bind(this)
            );
        }
    }

    nameInput.on('change.name', function () {
        nameInput.addClass('changed').off('change.name');
    });

    $(".save_as").off("click.onSaveAs");
    $(".save_as").on("click.onSaveAs", onSaveAs);
});

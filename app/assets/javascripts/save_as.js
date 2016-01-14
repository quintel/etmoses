/*globals document,customPrompt*/
$(document).on('page:change', function () {
    'use strict';

    function submitSaveAsForm() {
        var form = $(this).parents("form");
        form.attr("action", $(this).data('url'));
        form.submit();
    }

    $(".save_as").on("click", function (e) {
        e.preventDefault();

        var nameInput = $("input#testing_ground_name");

        customPrompt("Please set a name for your new LES", nameInput.val(), function (newName) {
            nameInput.val(newName);

            submitSaveAsForm.call(this);
        }.bind(this));
    });
});

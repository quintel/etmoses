/*globals document,customPrompt*/
$(document).on('page:change', function () {
    'use strict';

    var nameInput = $("input#testing_ground_name");

    function submitSaveAsForm() {
        var form = $(this).parents("form");
        form.attr("action", $(this).data('url'));
        form.submit();
    }

    nameInput.on('change.name', function () {
        nameInput.addClass('changed').off('change.name');
    });

    $(".save_as").on("click", function (e) {
        e.preventDefault();

        if (nameInput.hasClass('changed')) {
            submitSaveAsForm.call(this);
        } else {
            customPrompt(
                "Please set a name for your new LES",
                nameInput.val(),
                function (newName) {
                    nameInput.val(newName);

                    submitSaveAsForm.call(this);
                }.bind(this)
            );
        }
    });
});

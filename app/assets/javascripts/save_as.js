/*globals document*/
$(document).on('page:change', function () {
    'use strict';

    function submitSaveAsForm() {
        var form = $(this).parents("form");
        form.attr("action", $(this).data('url'));
        form.removeAttr("data-remote");
        form.submit();
    }

    $(".save_as").on("click", function (e) {
        e.preventDefault();

        window.saveAll.submitForms(submitSaveAsForm.bind(this));
    });
});

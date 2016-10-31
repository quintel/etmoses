$(document).on("page:change", function () {
    'use strict';

    var permissions;

    $("input#topology_template_featured")
        .off('change')
        .on('change', function () {
            permissions = $(this).parents("form").find(".permissions");

            if ($(this).is(":checked")) {
                permissions.find("input").prop('disabled', true);
                permissions.find("input[id$='true']").prop('checked', true);
            } else {
                permissions.find("input").prop('disabled', false);
            }
        })
        .trigger('change');
});

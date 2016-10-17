/*globals BusinessCaseTable*/

$(document).on("page:change", function () {
    'use strict';

    if ($("#business_case_target_area").length > 0) {
        new BusinessCaseTable("#business_case_table").reload();
    }
});

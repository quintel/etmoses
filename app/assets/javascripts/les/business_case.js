$(document).on("page:change", function () {
    if ($("#business_case_target_area").length > 0) {
        new BusinessCaseTable("#business_case_table").reload();
    }
});

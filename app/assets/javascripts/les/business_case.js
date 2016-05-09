$(document).on("page:change", function () {
    if ($("#business_case_target_area").length > 0) {
        $("ul.nav.nav-tabs li.business_case").addClass("active");

        new BusinessCaseTable("#business_case_table").reload();
    }
});

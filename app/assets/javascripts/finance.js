/*globals BusinessCaseTable,FinanceTable*/

$(document).on("page:change", function () {
    'use strict';

    var financeTable = $("table.finance-table");

    if (financeTable.length > 0) {
        new FinanceTable(financeTable).create();

        $(financeTable).find(".row_value input").on('change', function () {
            $(".edit_business_case, a[href='#business-case']").addClass("editing");
        });
    }

    new BusinessCaseTable($("#business_case_table")).create();
});

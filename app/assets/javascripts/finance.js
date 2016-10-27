/*globals BusinessCaseTable,FinanceTable*/

$(document).on("page:change", function () {
    'use strict';

    var tab          = new Tab("#business-case"),
        financeTable = $("table.finance-table");

    if (financeTable.length > 0) {
        new FinanceTable(financeTable).create();

        $(financeTable)
            .find(".row_value input")
            .on('change', function () {
                tab.markAsEditing();
            });
    }
});

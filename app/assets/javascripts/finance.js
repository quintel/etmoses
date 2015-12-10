/*globals FinanceTable,Poller,StrategyHelper*/
$(document).on("page:change", function () {
    'use strict';

    var financeTable = $("table.finance-table"),
        businessCaseTable = $("#business_case_table");

    if (financeTable.length > 0) {
        new FinanceTable(financeTable).create();

        $(financeTable).find(".row_value input").on('change', function () {
            $(".edit_business_case, a[href='#business-case']").addClass("editing");
        });
    }

    function renderSummary() {
        $.ajax({
            type: "POST",
            url: businessCaseTable.data('finishUrl'),
        });
    }

    if (businessCaseTable.length > 0) {
        new Poller({
            url: businessCaseTable.data('url'),
            data: StrategyHelper.getStrategies()
        }).poll().done(renderSummary);
    }
});

var FinanceTable = (function () {
    'use strict';

    var financeTable, incomingTotal, currentFinances, financeArea,
        freeformRow, rowHeight;

    function updateCurrentFinances() {
        currentFinances[rowHeight] = freeformRow;
        financeArea.text(JSON.stringify(currentFinances));
    }

    function setTotalAndFormat(total) {
        $(this).text(total);
        $(this).formatCurrency();
    }

    function calculateIncomingTotal() {
        var incoming = 0;
        $(this).find("td:not(.center) span").each(function () {
            incoming += parseFloat($(this).data('value'));
        });
        return incoming;
    }

    function calculateIncomingRowTotals() {
        incomingTotal = calculateIncomingTotal.call(this);

        setTotalAndFormat.call($(this).find("td.incoming_total"), incomingTotal);
    }

    function calculateVertically(i, findCellValue) {
        var row, cell, calculation = 0;

        $(this).find("td").each(function (j) {
            row = $(financeTable.find("tbody tr")[j]);
            cell = $(row.find("td.row_value")[i]);

            calculation += parseFloat(findCellValue.call(cell) || 0.0);
        });

        return calculation;
    }

    function calculateOutgoing(i) {
        return calculateVertically.call(this, i, function () {
            return this.find("span").data("value");
        });
    }

    function calculateFreeform(i) {
        return calculateVertically.call(this, i, function () {
            return this.find("input.free-form").val();
        });
    }

    function calculateOutgoingRowTotals(i) {
        var outgoing = calculateOutgoing.call(this, i),
            freeform = calculateFreeform.call(this, i),
            total = outgoing + freeform;

        setTotalAndFormat.call($(financeTable.find("td.total")[i]), total);

        if (!$(this).hasClass("freeform")) {
            freeformRow.freeform[i] = freeform;
        }
    }

    function calculateTotals() {
        financeTable.find("tbody tr.stakeholder").each(calculateIncomingRowTotals);
        financeTable.find("tbody tr").each(calculateOutgoingRowTotals);

        updateCurrentFinances();
    }

    FinanceTable.prototype = {
        create: function () {
            financeArea = $("form #business_case_financials");
            rowHeight = financeTable.find("tbody tr.stakeholder").length;
            currentFinances = JSON.parse(financeArea.text()) || {};
            freeformRow = (currentFinances[rowHeight] || {
                freeform: []
            });

            calculateTotals();

            $(financeTable).find("td.row_value input").on('change', calculateTotals);
        }
    };

    function FinanceTable(thisFinanceTable) {
        financeTable = thisFinanceTable;
    }

    return FinanceTable;
}());

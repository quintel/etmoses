$(document).on("page:change", function(){
  var formatCurrencyOptions = { symbol: '€' };
  var financeTable = $("table.finance-table");

  financeTable.find("tbody tr").each(calculateIncomingRowTotals);
  financeTable.find("tbody tr").each(calculateOutgoingRowTotals);

  function calculateIncomingRowTotals(){
    var incomingTotal = 0;
    var incomingTotalCell = $(this).find("td.incoming_total");

    $(this).find("td span").each(function(){
      incomingTotal += parseFloat($(this).data('value'));
    });

    incomingTotalCell.text(incomingTotal);
    incomingTotalCell.formatCurrency(formatCurrencyOptions);
  };

  function calculateOutgoingRowTotals(i){
    var outgoingTotal = 0;
    var totalCell = $(financeTable.find("td.total")[i]);

    $(this).find("td").each(function(j){
      var row  = $(financeTable.find("tbody tr")[j]);
      var cell = $(row.find("td.row_value")[i]);

      outgoingTotal += parseFloat(cell.find("span").data('value') || 0.0);
    });

    totalCell.text(outgoingTotal);
    totalCell.formatCurrency(formatCurrencyOptions);
  };
});

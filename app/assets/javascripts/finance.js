$(document).on("page:change", function(){
  var formatCurrencyOptions = { symbol: '€' };
  var financeTable = $("table.finance-table");

  calculateTotals();

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
      var row   = $(financeTable.find("tbody tr")[j]);
      var cell  = $(row.find("td.row_value")[i]);
      var value = (cell.find("span").data('value') || cell.find('input').val() || 0.0);

      outgoingTotal += parseFloat(value);
    });

    totalCell.text(outgoingTotal);
    totalCell.formatCurrency(formatCurrencyOptions);
  };

  $("td.row_value input").on('change', calculateTotals);

  function calculateTotals(){
    financeTable.find("tbody tr").each(calculateIncomingRowTotals);
    financeTable.find("tbody tr").each(calculateOutgoingRowTotals);
  };
});

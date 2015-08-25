var FinanceTable = (function(){
  var financeTable, incomingTotal, outgoingTotal, currentFinances, financeArea,
      freeformRow, rowHeight;

  FinanceTable.prototype = {
    create: function(){
      financeArea     = $("form #business_case_financials");
      rowHeight       = financeTable.find("tbody tr.stakeholder").length;
      currentFinances = JSON.parse(financeArea.text());
      freeformRow     = (currentFinances[rowHeight] || { freeform: [] });

      calculateTotals();

      $(financeTable).find("td.row_value input").on('change', calculateTotals);
    }
  };

  function calculateTotals(){
    financeTable.find("tbody tr.stakeholder").each(calculateIncomingRowTotals);
    financeTable.find("tbody tr").each(calculateOutgoingRowTotals);

    updateCurrentFinances();
  };

  function calculateIncomingRowTotals(i){
    incomingTotal = calculateIncomingTotal.call(this);

    setTotalAndFormat.call($(this).find("td.incoming_total"), incomingTotal);
  };

  function calculateIncomingTotal(){
    var incoming = 0;
    $(this).find("td span").each(function(){
      incoming += parseFloat($(this).data('value'));
    });
    return incoming;
  };

  function calculateOutgoingRowTotals(i){
    outgoing = calculateOutgoing.call(this, i);
    freeform = calculateFreeform.call(this, i);

    total = outgoing + freeform;

    setTotalAndFormat.call($(financeTable.find("td.total")[i]), total);

    if(!$(this).hasClass("freeform")){
      freeformRow.freeform[i] = freeform;
    };
  };

  function calculateOutgoing(i){
    return calculateVertically.call(this, i, function(){
      return this.find("span").data("value");
    });
  };

  function calculateFreeform(i){
    return calculateVertically.call(this, i, function(){
      return this.find("input.free-form").val();
    });
  };

  function calculateVertically(i, findCellValue){
    var calculation = 0;

    $(this).find("td").each(function(j){
      var row  = $(financeTable.find("tbody tr")[j]);
      var cell = $(row.find("td.row_value")[i]);

      calculation += parseFloat(findCellValue.call(cell) || 0.0);
    });

    return calculation;
  };

  function setTotalAndFormat(total){
    $(this).text(total);
    $(this).formatCurrency(Finance.currencyOptions);
  };

  function updateCurrentFinances(){
    currentFinances[rowHeight] = freeformRow;
    financeArea.text(JSON.stringify(currentFinances));
  };

  function FinanceTable(_financeTable){
    financeTable = _financeTable;
  };

  return FinanceTable;
})();

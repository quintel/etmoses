Finance = {
  currencyOptions: {
    symbol: '€',
    negativeFormat: "-%s%n"
  }
};

$(document).on("page:change", function(){
  var financeTable = $("table.finance-table");

  if(financeTable.length > 0){
    new FinanceTable(financeTable).create();
  }
});

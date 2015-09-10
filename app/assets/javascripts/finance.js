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

  var businessCaseTable = $("#business_case_table");

  if(businessCaseTable.length > 0){
    new Poller({
      url: businessCaseTable.data('url'),
      data: TopologyTreeHelper.strategies(),
      hooks: {
        final_success: renderSummary
      }
    }).poll();
  };

  function renderSummary(){
    $.ajax({
      type: "POST",
      url:  businessCaseTable.data('finishUrl'),
    });
  };
});


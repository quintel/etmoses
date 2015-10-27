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
    $(financeTable).find(".row_value input").on('change', function(){
      $(".edit_business_case, a[href='#business-case']").addClass("editing");
    });
  }

  var businessCaseTable = $("#business_case_table");

  if(businessCaseTable.length > 0){
    var poller = new Poller({
      url: businessCaseTable.data('url'),
      data: StrategyHelper.getStrategies()
    }).poll().done(renderSummary);
  };

  function renderSummary(){
    $.ajax({
      type: "POST",
      url:  businessCaseTable.data('finishUrl'),
    });
  };
});


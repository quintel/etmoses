$(document).on("page:change", function(){
  var compareSelectBox = $(".container .compare select");
  var compareTable     = $("table.compare");
  var leftBracket      = $("<span>").text("(");
  var rightBracket     = $("<span>").text(")");

  if(compareSelectBox.length > 0){
    compareSelectBox.on("change", compareBusinessCase);
    compareSelectBox.prop('disabled', false);
    sumRows();
  }

  function compareBusinessCase(){
    $(this).prop('disabled', true);
    $.ajax({
      url: $(this).data('compareUrl'),
      type: "POST",
      data: { comparing_testing_ground_id: $(this).val() },
      success: updateTable
    });
  };

  function updateTable(data){
    setDifferences(data);

    compareSelectBox.prop('disabled', false);
  };

  function setDifferences(data){
    var rows = compareTable.find("tbody tr");

    for(var i = 0; i < data.length; i++){
      updateRow.call({ row: rows[i], data: data[i] });
    };
  };

  function updateRow(){
    var cells = $(this.row).find("td.editable");

    for(var j = 0; j < this.data.length; j++){
      updateCell.call({ cell: cells[j], data: this.data[j] });
    };
  };

  function updateCell(){
    var difference = $(this.cell).find("span.difference");
    var calc = $("<span>").addClass("calc").text(this.data);

    if(cell.find("span.static").text() !== ""){
      difference.html("");
      difference.append(leftBracket.clone(), calc, rightBracket.clone());
      difference.find(".calc").formatCurrency(Finance.currencyOptions);
    };
  };

  function sumRows(){
    compareTable.find("tr").each(function(i, row){
      var total = 0;
      $(row).find(".editable .static").each(function(j, value){
        total += (parseFloat($(value).text()) || 0.0);
      });

      $(row).find(".total").text(total);
    });
  };

  compareTable.find("td.editable .static, td.total").formatCurrency(Finance.currencyOptions);
});

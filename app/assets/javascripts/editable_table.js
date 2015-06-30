var EditableTable = (function(){
  var selector, changeData, changeListener;

  EditableTable.prototype = {
    append: function(_changeListener, _changeData){
      changeListener = (_changeListener || function(){});
      changeData = (_changeData || function(){});

      $(selector).on('change', changeListener.bind(this));

      addClickListenersToAddRow();
      addClickListenersToDeleteRow();
    },

    getData: function(){
      return tableToProfile();
    }
  };

  function tableToProfile(){
    return tableRows().map(function(tableRow){
      return rowToTechnologyObject(tableRow);
    });
  };

  function rowToTechnologyObject(tableRow){
    var tableData = {};
    $.each(tableRow, function(i, attribute){
      var header = tableHeader(i);
      tableData[header] = attribute;
      changeData.call({ attribute: attribute, header: header, tableData: tableData });
    });
    return tableData;
  };

  function tableHeader(index){
    return $($(selector).find("thead th")[index]).data("header");
  };

  function tableRows(){
    return $(selector).find("tbody tr").toArray().map(extractTextfromCells);
  };

  function extractTextfromCells(row){
    return $(row).find("td.editable").toArray().map(function(cell){
      if($(cell).find("select:visible").length > 0){
        return $.trim($(cell).find("select").val());
      }
      else{
        return $.trim($(cell).find("input").val());
      }
    });
  };

  function addClickListenersToAddRow(){
    $(selector).find("a.add-row").on("click", function(){
      var row = $(this).parents("tr");
      var clonedRow = row.clone(true, true);
      clonedRow.insertAfter(row);
      changeListener.call();
    });
  };

  function addClickListenersToDeleteRow(){
    $(selector).find("a.remove-row").on("click", function(){
      $(this).parents("tr").remove();
      changeListener.call();
    });
  };

  function EditableTable(_selector){
    selector = _selector;
  };

  return EditableTable;
})();

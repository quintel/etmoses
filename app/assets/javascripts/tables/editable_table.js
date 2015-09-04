var EditableTable = (function(){
  var selector, changeData, changeListener;

  EditableTable.prototype = {
    append: function(_changeListener, _changeData){
      changeListener = (_changeListener || function(){});
      changeData = (_changeData || function(){});

      $(this.selector).on('change', changeListener.bind(this));

      addClickListenersToAddRow.call(this);
      addClickListenersToDeleteRow.call(this);
    },

    getData: function(){
      return tableToProfile.call(this);
    }
  };

  function tableToProfile(){
    var self = this;
    return tableRows.call(this).map(function(tableRow){
      return rowToTechnologyObject.call(self, tableRow);
    });
  };

  function rowToTechnologyObject(tableRow){
    var tableData = {};
    var self = this;
    $.each(tableRow, function(i, attribute){
      var header = tableHeader.call(self, i);
      tableData[header] = attribute;
      changeData.call({ attribute: attribute, header: header, tableData: tableData });
    });
    return tableData;
  };

  function tableHeader(index){
    return $($(this.selector).find("thead th")[index]).data("header");
  };

  function tableRows(){
    return $(this.selector).find("tbody tr").toArray().map(extractTextfromCells);
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
    $(this.selector).find("a.add-row").on("click", function(e){
      e.preventDefault();

      var row = $(this).parents("tr");
      var clonedRow = row.clone(true, true);
      clonedRow.insertAfter(row);
      changeListener.call();
    });
  };

  function addClickListenersToDeleteRow(){
    $(this.selector).find("a.remove-row").on("click", function(e){
      e.preventDefault();

      $(this).parents("tr").remove();
      changeListener.call();
    });
  };

  function EditableTable(_selector){
    this.selector = _selector;
  };

  return EditableTable;
})();

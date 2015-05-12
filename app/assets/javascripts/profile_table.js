var ProfileTable = (function(){
  var widget, selector;

  ProfileTable.prototype = {
    append: function(){
      widget = $(selector).editableTableWidget();
      widget.on('change', parseTableToJSON.bind(this));

      addClickListenersToAddRow();
      addClickListenersToDeleteRow();
      parseTableToJSON();
    }
  };

  function parseTableToJSON(){
    $("#testing_ground_technology_profile").text(tableToProfile());
  };

  function tableToProfile(){
    var technologyProfile = tableRows().map(function(tableRow){
      return rowToTechnologyObject(tableRow);
    });
    return JSON.stringify(ETHelper.groupBy(technologyProfile, 'node'));
  };

  function rowToTechnologyObject(tableRow){
    var technologyObject = {};
    $.each(tableRow, function(i, technology){
      technologyObject[tableHeader(i)] = technology
    });
    return technologyObject;
  };

  function tableHeader(index){
    return $(selector).find("thead th")[index].innerHTML.toLowerCase();
  };

  function tableRows(){
    var rows = [];
    $(selector).find("tbody tr").each(function(){
      var tableCells = $(this).find("td:first-child, td.editable");
      var tableText = tableCells.toArray().map(function(cell){
        return $.trim($(cell).text());
      });

      rows.push(tableText);
    });
    return rows;
  };

  function addClickListenersToAddRow(){
    $("#profiles-table table tr th a.add-row").on("click", function(){
      var row = $(this).parents("tr");
      var clonedRow = row.clone(true, true);
      clonedRow.find("td.editable").text("");
      clonedRow.insertAfter(row);
    });
  };

  function addClickListenersToDeleteRow(){
    $("#profiles-table table tr th a.remove-row").on("click", function(){
      $(this).parents("tr").remove();
      parseTableToJSON();
    });
  };

  function ProfileTable(_selector){
    selector = _selector;
  };

  return ProfileTable;
})();

$(document).on("page:change", function(){
  window.currentProfileTable = new ProfileTable("#profiles-table table");
  window.currentProfileTable.append();
});

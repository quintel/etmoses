var ProfileTable = (function(){
  var widget, selector;

  ProfileTable.prototype = {
    append: function(){
      widget = $(selector).editableTableWidget();
      widget.on('change', updateProfiles.bind(this));
      addClickListenersToAddRow();
      addClickListenersToDeleteRow();
      updateProfiles();
    }
  };

  function updateProfiles(){
    var headers = tableHeaders();
    var technologyProfile = [];
    $.each(tableRows(), function(a,tableRow){
      var technologyObject = {};
      $.each(tableRow, function(b, technology){
        technologyObject[headers[b].toLowerCase()] = technology
      });
      technologyProfile.push(technologyObject);
    });

    var object = _.groupBy(technologyProfile, 'node');
    $("#testing_ground_technology_profile").text(JSON.stringify(object));
  };

  function tableHeaders(){
    return $(selector).find("thead th").map(function(){
      return $(this).text();
    });
  };

  function tableRows(){
    var rows = [];
    $(selector).find("tbody tr").each(function(){
      var tableText = [];
      $(this).find("td:first-child, td.editable").each(function(){
        tableText.push($.trim($(this).text()));
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
    });
  };

  function ProfileTable(_selector){
    selector = _selector;
  };

  return ProfileTable;
})();

$(document).on("page:change", function(){
  new ProfileTable("#profiles-table table").append();
});

var ProfileTable = (function(){
  var widget, selector;

  ProfileTable.prototype = {
    append: function(){
      widget = $(selector).editableTableWidget();
      widget.on('change', parseTableToJSON.bind(this));

      addClickListenersToAddRow();
      addClickListenersToDeleteRow();
      addProfileSelectBoxes();
      addChangeListenerToNameBox();
      parseTableToJSON();
    },

    updateProfiles: function(){
      $("select.name").each(function(){
        $(this).parent().next().find("select").val($(this).data('profile'));
      });
    }
  };

  function addProfileSelectBoxes(){
    $("select.name").each(function(){
      cloneAndAppendProfileSelect.call(this);
    });
  };

  function addChangeListenerToNameBox(){
    $("select.name").off().on("change", function(){
      cloneAndAppendProfileSelect.call(this);
    });
  };

  function cloneAndAppendProfileSelect(){
    var technology = $(this).val();
    var profileSelectbox = $(".hidden.profile select." + technology).clone();
    profileSelectbox.val($(this).data('profile'));
    $(this).parent().next().html(profileSelectbox);
  };

  function parseTableToJSON(){
    var tableProfile = tableToProfile();
    var groupedByNode = ETHelper.groupBy(tableProfile, 'node');

    $("#technology_distribution").text(JSON.stringify(tableProfile));
    $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
  };

  function tableToProfile(){
    return tableRows().map(function(tableRow){
      return rowToTechnologyObject(tableRow);
    });
  };

  function rowToTechnologyObject(tableRow){
    var technologyObject = {};
    $.each(tableRow, function(i, techAttribute){
      var header = tableHeader(i);

      if(header == "name"){
        technologyObject["name"] = getNameForType(techAttribute);
        technologyObject["type"] = techAttribute;
      }
      else if(!(/demand|capacity/.test(header) && techAttribute == "")){
        technologyObject[header] = techAttribute;
      };
    });
    return technologyObject;
  };

  function getNameForType(type){
    var selectedOption = $("select.name").first().find("option").filter(function(){
      return $(this).val() == type;
    });
    return selectedOption.text();
  };

  function tableHeader(index){
    return $($(selector).find("thead th")[index]).data("header");
  };

  function tableRows(){
    return $(selector).find("tbody tr").toArray().map(extractTextfromCells);
  };

  function extractTextfromCells(row){
    return $(row).find("td.editable").toArray().map(function(cell){
      if($(cell).hasClass("select")){
        return $.trim($(cell).find("select").val());
      }
      else{
        return $.trim($(cell).text());
      }
    });
  };

  function addClickListenersToAddRow(){
    $("#profiles-table table tr th a.add-row").on("click", function(){
      var row = $(this).parents("tr");
      var clonedRow = row.clone(true, true);
      clonedRow.find("td.editable:not(.select)").text("");
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

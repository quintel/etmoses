var ProfileTable = (function(){
  var widget, selector, profileSelectBoxes;
  var EDSN_THRESHOLD = 10;

  ProfileTable.prototype = {
    append: function(){
      profileSelectBoxes.add();
      addChangeListenersToHouseholds();
      editableTable.append(parseTableToJSON, changeData);
    },

    updateProfiles: function(){
      profileSelectBoxes.update();
    }
  };

  function addChangeListenersToHouseholds(){
    $("select.base_load:visible").each(function(){
      var select = this;
      var unitsInput = $(select).parents("tr").find(".units input");

      toggleEDSNProfiles.call(this, unitsInput.val());

      unitsInput.off("change").on("change", function(){
        toggleEDSNProfiles.call(select, $(this).val());
      });
    });
  };

  function toggleEDSNProfiles(value){
    $(this).val(function(){
      return $(this).find("option[data-edsn=" + (value > EDSN_THRESHOLD) + "]").val();
    });
  };

  function parseTableToJSON(){
    var tableProfile = editableTable.getData();
    var groupedByNode = ETHelper.groupBy(tableProfile, 'node');

    $("#technology_distribution").text(JSON.stringify(tableProfile));
    $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
  };

  function changeData(){
    if(this.header == "name"){
      this.tableData["name"] = getNameForType(this.attribute);
      this.tableData["type"] = this.attribute;
    }
    else if(!(/demand|capacity/.test(this.header) && this.attribute == "")){
      this.tableData[this.header] = this.attribute
    };
  };

  function getNameForType(type){
    var selectedOption = $("select.name").first().find("option").filter(function(){
      return $(this).val() == type;
    });
    return selectedOption.text();
  };

  function ProfileTable(_selector){
    selector = _selector;
    profileSelectBoxes = new ProfileSelectBoxes();
    editableTable = new EditableTable(_selector);
  };

  return ProfileTable;
})();

$(document).on("page:change", function(){
  if($("#profiles-table table").length > 0){
    window.currentProfileTable = new ProfileTable("#profiles-table table");
    window.currentProfileTable.append();
  }
});

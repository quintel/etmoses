var ProfileTable = (function(){
  var widget, selector, profileSelectBoxes, edsnSwitch;

  ProfileTable.prototype = {
    append: function(){
      profileSelectBoxes.add();
      edsnSwitch.enable();

      editableTable.append(parseTableToJSON, changeData);
      parseTableToJSON();
    },

    updateProfiles: function(){
      profileSelectBoxes.update();
      parseTableToJSON();
    }
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
      if(type == "base_load_edsn"){
        type = "base_load";
      };
      return $(this).val() == type;
    });
    return selectedOption.text();
  };

  function ProfileTable(_selector){
    selector           = _selector;
    editing            = $("form.edit_testing_ground").length > 0;
    edsnSwitch         = new EdsnSwitch(editing);
    profileSelectBoxes = new ProfileSelectBoxes(edsnSwitch);
    editableTable      = new EditableTable(_selector);
  };

  return ProfileTable;
})();

$(document).on("page:change", function(){
  if($("#profiles-table > table").length > 0){
    window.currentProfileTable = new ProfileTable("#profiles-table > table");
    window.currentProfileTable.append();
  }
});

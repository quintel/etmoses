var ProfileSelectBoxes = (function(){
  var etmDefaults, edsnSwitch;
  var defaultCells = ["Capacity", "Volume", "Demand"];

  ProfileSelectBoxes.prototype = {
    add: function(){
      addProfileSelectBoxes();
      addChangeListenerToNameBox();
      addChangeListenerToProfileBox();
    },

    update: function(){
      updateSelectBoxes();
    }
  };

  function updateSelectBoxes(){
    $("select.name").each(function(){
      $(this).parent().next().find("select").val($(this).data('profile'));
    });
  };

  function addProfileSelectBoxes(){
    $("select.name").each(function(){
      cloneAndAppendProfileSelect.call(this, false);
    });
  };

  function addChangeListenerToNameBox(){
    $("select.name").off("change").on("change", function(){
      cloneAndAppendProfileSelect.call(this, true);
    });
  };

  function addChangeListenerToProfileBox(){
    $("td.profile select").off().on("change", function(){
      updateTextCells(this, $(this).parents("tr"));
    });
  };

  function cloneAndAppendProfileSelect(isChanged){
    if(edsnSwitch.isEdsn.call(this)){
      edsnSwitch.cloneAndAppendProfileSelect.call(this, isChanged);
    }
    else{
      defaultCloneAndAppend.call(this, isChanged);
    }
  };

  function defaultCloneAndAppend(isChanged){
    var technology = $(this).val();
    var profileSelectbox = $(".hidden.profile select." + technology).clone(true, true);

    $(this).parent().next().html(profileSelectbox);

    updateTextCells(profileSelectbox, $(this).parents("tr"), isChanged);

    if(!isChanged){
      profileSelectbox.val($(this).data('profile'));
    };
  };

  function updateTextCells(profileSelectbox, currentRow, clearValues){
    var selected = $(profileSelectbox).val();
    var selectedOption = $(profileSelectbox).find("option[value='" + selected + "']");
    var defaults = selectedOption.data();

    if(defaults){
      for(var i = 0; i < defaultCells.length; i++){
        setCellDefault.call({
                cell: defaultCells[i],
          currentRow: currentRow,
               clear: clearValues,
            defaults: defaults
        });
      };
    };
  };

  function setCellDefault(){
    var technology = this.currentRow.find("select.name").val();
    var inputField = this.currentRow.find("." + this.cell.toLowerCase() + " input");
    var dbDefault  = this.defaults["default" + this.cell];
    var etmValue   = defaultsForTech(technology)[this.cell.toLowerCase()];
    var userInput  = parseFloat(inputField.val());

    if(etmValue == userInput || this.clear) userInput = undefined;

    inputField.val(userInput || etmValue || dbDefault || '');
  };

  function defaultsForTech(tech){
    return etmDefaults[tech] ? etmDefaults[tech][0] : {};
  };

  function setEtmDefaults(){
    var profile = JSON.parse($("#testing_ground_technology_profile").text());
    var technologies = []

    Object.keys(profile).map(function(key){
      technologies = technologies.concat(profile[key])
    });

    return ETHelper.groupBy(technologies, 'type');
  };

  function ProfileSelectBoxes(_edsnSwitch){
    etmDefaults = setEtmDefaults();
    edsnSwitch = _edsnSwitch;
  };

  return ProfileSelectBoxes;
})();

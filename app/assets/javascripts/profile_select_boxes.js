var ProfileSelectBoxes = (function(){
  var defaultCells = ["Capacity", "Volume", "Demand"];
  var EDSN_THRESHOLD = 30;

  ProfileSelectBoxes.prototype = {
    add: function(){
      updateEdsnProfiles();
      addProfileSelectBoxes();
      addChangeListenerToNameBox();
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
    $("select.name").off().on("change", function(){
      cloneAndAppendProfileSelect.call(this, true);
    });
  };

  function updateEdsnProfiles(){
    $("tr.base_load, tr.base_load_edsn").each(function(){
      var select = $(this).find("td.select select.name");
      var unitsInput = $(this).find(".units input");

      toggleEDSNProfiles.call(select, unitsInput.val());

      unitsInput.off("change").on("change", function(){
        toggleEDSNProfiles.call(select, $(this).val());
      });
    });
  };

  function toggleEDSNProfiles(value){
    var baseLoadTech = (value > EDSN_THRESHOLD ? "base_load_edsn" : "base_load");

    $(this).val(baseLoadTech);
    $(this).data('profile', $("select." + baseLoadTech).val());
    $(this).trigger('change');
  };

  function cloneAndAppendProfileSelect(isChanged){
    var technology = $(this).val();
    var profileSelectbox = $(".hidden.profile select." + technology).clone();

    $(this).parent().next().html(profileSelectbox);

    if(isChanged){
      updateTextCells(profileSelectbox, $(this).parents("tr"));
    }
    else{
      profileSelectbox.val($(this).data('profile'));
    }
  };

  function updateTextCells(profileSelectbox, currentRow){
    for(var i = 0; i < defaultCells.length; i++){
      var cell = defaultCells[i];
      currentRow.find("." + cell.toLowerCase() + " input").val(
        profileSelectbox.data("defaults" + cell)
      );
    };
  };

  function ProfileSelectBoxes(){
  };

  return ProfileSelectBoxes;
})();

var ProfileSelectBoxes = (function(){
  var defaultCells = ["Capacity", "Volume", "Demand"];
  var EDSN_THRESHOLD = 30;

  ProfileSelectBoxes.prototype = {
    add: function(){
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

  function cloneAndAppendProfileSelect(isChanged){
    var technology = $(this).val();
    var units = $(this).parents("tr").find(".units input").val();

    if(technology == 'base_load' && units > EDSN_THRESHOLD){
      technology = "base_load_edsn";
    };

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

var ProfileSelectBoxes = (function(){
  var defaultCells = ["Capacity", "Volume", "Demand"];

  ProfileSelectBoxes.prototype = {
    add: function(){
      addProfileSelectBoxes();
      addChangeListenerToNameBox();
    },

    update: function(){
      $("select.name").each(function(){
        $(this).parent().next().find("select").val($(this).data('profile'));
      });
    }
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

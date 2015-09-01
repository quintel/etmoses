var EDSN_THRESHOLD = 30;

var EdsnSwitch = (function(){
  var editing;
  var validBaseLoads = /^(base_load|base_load_edsn)$/;

  EdsnSwitch.prototype = {
    enable: function(){
      if(editing){
        swapEdsnBaseLoadSelectBoxes();
      }
      else{
        addChangeListenerToNameBoxes();
        checkAllCurrentBaseLoads();
      }
    }
  };

  function swapEdsnBaseLoadSelectBoxes(){
    $("tr.base_load_edsn select.name").each(swapSelectBox);
  };

  function addChangeListenerToNameBoxes(){
    $("select.name").on("change", swapSelectBox);
  };

  function checkAllCurrentBaseLoads(){
    $("select.name").each(swapSelectBox);
  };

  function swapSelectBox(){
    var technology = $(this).val();

    if(validBaseLoads.test(technology)){
      var self         = this;
      var unitSelector = $(this).parents("tr").find(".units input");
      var units        = parseInt(unitSelector.val());
      var actual       = (units > EDSN_THRESHOLD ? "base_load_edsn" : "base_load");
      var select       = $(".hidden select." + actual).clone(true, true);

      $(this).parent().next().html(select);
      $(this).find("option[value='" + technology + "']").attr('value', actual);

      unitSelector.off('change').on('change', swapSelectBox.bind(self));
    };
  };

  function EdsnSwitch(_editing){
    editing = _editing;
  };

  return EdsnSwitch;
})();

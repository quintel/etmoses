$(document).on("page:change", function(){
  var EDSN_THRESHOLD = 10;

  $("select.base_load:visible").each(function(){
    var select = this;
    var unitsInput = $(select).parents("tr").find(".units input");

    toggleEDSNProfiles.call(this, unitsInput.val());

    unitsInput.on("change", function(){
      toggleEDSNProfiles.call(select, $(this).val());
    });
  });

  function toggleEDSNProfiles(value){
    $(this).val(function(){
      return $(this).find("option[data-edsn=" + (value > EDSN_THRESHOLD) + "]").val();
    });
  };
});

$(document).on("page:change", function(){
  var newImportForm = $("form#new_import");

  if(newImportForm.length > 0){
    function validateBusinessCase(){
      var data = {
        business_case: {
          topology_id:     newImportForm.find("select#import_topology_id").val(),
          market_model_id: newImportForm.find("select#import_market_model_id").val()
        }
      };

      $.ajax({ type: "POST",
              url: "/validate_business_case",
              data: data,
              success: displayWarning });
    };

    function displayWarning(data){
      $(".business-case-warning").toggleClass("hidden", data.valid);
    };

    validateBusinessCase();
    newImportForm.find("select").on('change', validateBusinessCase);
  };
});

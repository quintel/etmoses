$(document).on("page:change", function(){
  var businessCaseCreateButton = $("a.btn.business_case_create");

  if(businessCaseCreateButton.length > 0){
    businessCaseCreateButton.on('click', function(){
      if(!businessCaseCreateButton.hasClass("disabled")){
        businessCaseCreateButton.addClass("disabled");
        $("span.wait").removeClass("hidden");

        $.ajax({
          type: "POST",
          url: businessCaseCreateButton.data('url'),
          success: function(){
            businessCaseCreateButton.removeClass("disabled");
            $("span.wait").addClass("hidden");
          }
        });
      };
    });
  };
});

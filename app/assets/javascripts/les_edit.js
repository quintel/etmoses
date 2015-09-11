$(document).on("page:change", function(){
  $(".tab-content .remote form").on("submit", function(){
    $(this).find("input[type=submit]").addClass("disabled");
    $(this).find("span.wait").removeClass("hidden");
  });

  $(".remote form").on("change", function(){
    var tabTarget = $(this).parent().attr("id");
    var tabHeader = $("ul.nav-tabs li a[href='#" + tabTarget + "']");
    tabHeader.addClass("editing");
  });

  $(".save-all").on("click", function(e){
    e.preventDefault();

    var completeCount = 1;

    $(".save-all").addClass("disabled");
    $(".btn-group span.wait").removeClass("hidden");
    $(".remote form").submit();

    $("body").on("ajax:complete", function(){
      completeCount += 1;
      if(completeCount == $(".remote form").length){
        $(".btn-group span.wait").addClass("hidden");
        $(".save-all").removeClass("disabled");
      };
    });
  });
});

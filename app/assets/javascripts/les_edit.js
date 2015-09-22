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

  var saveAll = $("a.btn.save-all");
  var completeCount = 0;
  var current;

  saveAll.off("click").on("click", function(e){
    e.preventDefault();

    current = $(e.target);

    saveAll.addClass("disabled");
    $("span.save-all.wait").removeClass("hidden");

    submitForms();
  });

  function submitForms(){
    $(".remote form").each(function(){
      $(this).submit();
      $(this).on("ajax:success", finishAndRedirect);
    });
  };

  function finishAndRedirect(e){
    completeCount += 1;

    if(completeCount == $(".remote form").length){
      $("span.save-all.wait").addClass("hidden");
      saveAll.removeClass("disabled");

      window.location.replace(current.data('url'));
    };
  };
});

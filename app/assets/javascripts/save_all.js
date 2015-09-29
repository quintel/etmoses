var SaveAll = (function(){
  var saveAllButton;
  var completeCount = 0;

  SaveAll.prototype = {
    append: function(){
      saveAllButton.off("click").on("click", click.bind(this));
    },

    submitForms: function(success){
      $(".remote form").each(function(){
        $(this).submit();
        $(this).on("ajax:success", done.bind(this, success));
      });
    }
  };

  function click(e){
    e.preventDefault();

    completeCount = 0;

    saveAllButton.addClass("disabled");

    this.submitForms(finishAndRedirect);
  };

  function done(doneCallback){
    completeCount += 1;

    if(completeCount == $(".remote form").length){
      doneCallback.call();
    };
  };

  function finishAndRedirect(){
    saveAllButton.removeClass("disabled");

    window.location.replace(saveAllButton.data('url'));
  };

  function SaveAll(){
    saveAllButton = $("a.btn.save-all");
  };

  return SaveAll;
})();

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

  window.saveAll = new SaveAll();
  window.saveAll.append();
});

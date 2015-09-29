$(document).on('page:change', function(){
  $(".save_as").on("click", function(e){
    e.preventDefault();

    window.saveAll.submitForms(submitSaveAsForm.bind(this));
  });

  function submitSaveAsForm(){
    var form = $(this).parents("form")
    form.attr("action", $(this).data('url'))
    form.removeAttr("data-remote");
    form.submit();
  };
});

$(document).on('page:change', function(){
  $(".save_as").on("click", function(e){
    e.preventDefault();

    var form = $(this).parents("form")
    form.attr("action", $(this).data('url'))
    form.submit();
  });
});

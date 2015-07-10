$(document).on("page:change", function(){
  var profileCategoryId = $('#load_profile_load_profile_category_id');

  categoryChangeListener.call(profileCategoryId);
  profileCategoryId.on('change', categoryChangeListener);

  function categoryChangeListener(){
    var selectedOption = $(this).find("option[value='" + $(this).val() + "']")

    $(".profile-curve-file-field").hide().each(function(i){
      if(i <= (selectedOption.data("numberOfCurves") - 1)){
        $($(".profile-curve-file-field").get(i)).show();
      }
    });
  };
});

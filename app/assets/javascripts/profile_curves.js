$(document).on("page:change", function(){
  var profileCategoryId = $('#load_profile_load_profile_category_id');

  if(profileCategoryId.length > 0){
    var curveTypes = JSON.parse($(".curve_types.hidden").text());

    function categoryChangeListener(){
      var selectedOption = $(this).find("option[value='" + $(this).val() + "']")
      var selectedCurveTypes = curveTypes[selectedOption.data('curveType') || 'default'];

      $(".profile-curve-file-field").hide().each(function(i){
        $.each(selectedCurveTypes, function(i, curveType){
          $(".profile-curve-file-field." + curveType).show();
        });
      });
    };

    categoryChangeListener.call(profileCategoryId);
    profileCategoryId.on('change', categoryChangeListener);
  };
});

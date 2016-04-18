$(document).on("page:change", function () {
    'use strict';

    var selectedOption,
        selectedCurveTypes,
        curveTypes,
        profileCategoryId = $('#load_profile_load_profile_category_id');

    function categoryChangeListener() {
        selectedOption = $(this).find("option[value='" + $(this).val() + "']");
        selectedCurveTypes = curveTypes[selectedOption.data('curveType') || 'default'];

        $(".profile-curve-file-field").hide().each(function () {
            $.each(selectedCurveTypes, function (i, curveType) {
                $(".profile-curve-file-field." + curveType).show();
            });
        });
    }

    if (profileCategoryId.length > 0) {
        curveTypes = JSON.parse($(".curve_types.hidden").text());

        categoryChangeListener.call(profileCategoryId);
        profileCategoryId.on('change', categoryChangeListener);
    }
});

$(document).on("page:change", function(){
  $("select.multi-select").multiselect({
    buttonWidth: '200px',
    nonSelectedText: "Pick a strategy"
  });

  var cappingInput = $("input[type=checkbox][value=capping_solar_pv]")
  cappingInput.parents('a').append($(".slider-wrapper.hidden"));

  cappingInput.on("change", showSlider);

  showSlider.call(cappingInput);

  function showSlider(){
    var sliderWrapper = $(this).parents('a').find(".slider-wrapper");
    if($(this).is(":checked")){
      sliderWrapper.removeClass("hidden");
    }
    else{
      sliderWrapper.addClass("hidden");
    }
  };

  $("#solar_pv_capping").slider({
    focus: true,
    formatter: function(value){
      return value + "%";
    }
  });
});

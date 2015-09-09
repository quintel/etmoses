$(document).on("page:change", function(){
  $("select.multi-select").multiselect({
    buttonText: function(options) {
      var text = 'Customise technology behaviour';

      if (options.length) {
        text = text + ' (' + options.length + ' selected)';
      }

      return text;
    },
    dropRight: true
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

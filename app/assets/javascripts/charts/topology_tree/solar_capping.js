$(document).on("page:change", function(){
  var cappingSolarPv = $("input#capping_solar_pv");
      cappingSolarPv.on("change", showSlider);

  showSlider.call(cappingSolarPv);

  function showSlider(){
    var sliderWrapper = $("#collapse-strategies .slider-wrapper");
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

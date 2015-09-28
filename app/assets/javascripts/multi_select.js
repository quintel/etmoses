$(document).on("page:change", function(){
  var saveStrategies;

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

  if($(".save_strategies").length > 0){
    var selected = [];
    saveStrategies = JSON.parse($(".save_strategies").text());

    for(var strategy in saveStrategies){
      if(saveStrategies[strategy]){
        selected.push(strategy);
      }
    };

    $("select.multi-select").multiselect('select', selected);
    $("#solar_pv_capping").slider({
      focus: true,
      formatter: function(value){
        return value + "%";
      }
    }).slider('setValue', saveStrategies.capping_fraction * 100);
  };

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
});

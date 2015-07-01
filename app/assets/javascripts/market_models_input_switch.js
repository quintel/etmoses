$(document).on("page:change", function(){
  $("td.editable.input-switch ul.dropdown-menu li a").on("click", function(){
    var spanClass = $(this).find("span").attr("class");
    var cell = $(this).parents("td");
    var buttonGlyph = cell.find("button.dropdown-toggle span.glyphicon");
        buttonGlyph.removeClass().addClass(spanClass);

    cell.find(".financial-profiles, .fixed-price").toggle();

    window.currentMarketTable.updateTable();
  });

  $("td.editable.input-switch").each(function(){
    var inputPrice = $(this).data('price');
    if(inputPrice){
      if(typeof(inputPrice) == "string"){
        $(this).find("button.dropdown-toggle span.glyphicon")
          .removeClass("glyphicon-euro")
          .addClass("glyphicon-signal");

        $(this).find(".financial-profiles, .fixed-price").toggle();
        $(this).find(".financial-profiles select").val(inputPrice);
      }
      else if(typeof(inputPrice) == "number"){
        $(this).find("input").val(inputPrice);
      }
    };
  });
});

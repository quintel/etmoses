$(document).on("page:change", function(){
  $("select#stakeholders").on("change", function(){
    var stakeholderValue = $(this).val();

    d3.selectAll("g.node").attr("class", function(d){
      var currentClass = d3.select(this).attr("class");
      var isSelected = (new RegExp(stakeholderValue).test(currentClass) && stakeholderValue != "")
      d.node_selected = isSelected;

      if(isSelected){
        return currentClass + ' selected';
      }
      else{
        return currentClass.replace(/\sselected/, '');
      }
    });
  });
});

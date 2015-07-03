$(document).on("page:change", function(){
  if($("#import-mark").length > 0){
    $("a").filter(correctHref).attr("target", "_blank");
  };

  function correctHref(){
    return !this.href.match(/import\#/);
  };
});


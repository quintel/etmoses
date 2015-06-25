var MarketModelTable = (function(){
  var selector;

  MarketModelTable.prototype = {
    append: function(){
      editableTable.append(parseTableToJSON);
    }
  };

  function parseTableToJSON(){
    $("#market_model_interactions").text(JSON.stringify(editableTable.getData()));
  };

  function MarketModelTable(_selector){
    selector = _selector;
    editableTable = new EditableTable(selector);
  };

  return MarketModelTable;
})();

$(document).on("page:change", function(){
  new MarketModelTable("table.table.interactions").append();
});

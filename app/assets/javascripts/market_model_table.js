var MarketModelTable = (function(){
  var selector, editableTable;

  function MarketModelTable(_selector){
    selector = _selector;
    editableTable = new EditableTable(selector);
  };

  MarketModelTable.prototype = {
    append: function(){
      editableTable.append(this.updateTable);
    },

    updateTable: function(){
      $("#market_model_interactions").text(JSON.stringify(editableTable.getData()));
    }
  };

  return MarketModelTable;
})();

$(document).on("page:change", function(){
  window.currentMarketTable = new MarketModelTable("table.table.interactions");
  window.currentMarketTable.append();
});

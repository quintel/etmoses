var MarketModelTable = (function(){
  var editableTable;

  function MarketModelTable(_selector){
    editableTable = new EditableTable(_selector);
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

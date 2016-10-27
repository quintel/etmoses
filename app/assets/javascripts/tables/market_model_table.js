/*globals EditableTable*/

var MarketModelTable = (function () {
    'use strict';

    MarketModelTable.prototype = {
        append: function () {
            this.updateTable();

            this.editableTable.append(this.updateTable.bind(this));
        },

        updateTable: function () {
            $("#market_model_interactions").text(
                JSON.stringify(this.editableTable.getData())
            );
        }
    };

    function MarketModelTable(selector) {
        this.editableTable = new EditableTable(selector);
        this.tab           = new Tab("#market-model");
    }

    return MarketModelTable;
}());

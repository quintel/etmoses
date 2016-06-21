/*globals EditableTable*/

var MarketModelTable = (function () {
    'use strict';

    var editableTable;

    MarketModelTable.prototype = {
        append: function () {
            this.updateTable();

            editableTable.append(this.updateTable);
        },

        updateTable: function () {
            $("#market_model_interactions").text(
                JSON.stringify(editableTable.getData())
            );
        }
    };

    function MarketModelTable(selector) {
        editableTable = new EditableTable(selector);
    }

    return MarketModelTable;
}());

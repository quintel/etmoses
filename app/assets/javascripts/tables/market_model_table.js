/*globals EditableTable*/

var MarketModelTable = (function () {
    'use strict';

    MarketModelTable.prototype = {
        append: function () {
            this.updateTable();

            this.editableTable.append(this.updateTable.bind(this));

            $(this.selector).find("tbody").sortable({
                axis: "y",
                update: this.updateTable.bind(this)
            });
        },

        updateTable: function () {
            $(".market-model-interactions > textarea").text(
                JSON.stringify(this.editableTable.getData())
            );
        }
    };

    function MarketModelTable(selector) {
        this.selector      = selector;
        this.editableTable = new EditableTable(selector);
        this.tab           = new Tab("#market-model");
    }

    return MarketModelTable;
}());

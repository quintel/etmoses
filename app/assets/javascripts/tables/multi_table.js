var MultiTable = (function () {
    'use strict';

    function getData() {
        var result = [];

        this.tables.forEach(function (table) {
            result = result.concat(table.editableTable.getData());
        });

        return result;
    }

    function mergeAndUpdate() {
        var multiTableData = getData.call(this);

        $(this.scope).text(JSON.stringify(multiTableData));

        this.mergeCallback();
    }

    MultiTable.prototype = {
        add: function(table) {
            this.tables.push(table);

            table.editableTable.append(mergeAndUpdate.bind(this));
        }
    }

    function MultiTable(scope, mergeCallback) {
        this.scope         = scope;
        this.tables        = [];
        this.mergeCallback = mergeCallback || function () { return; };
    }

    return MultiTable;
}());

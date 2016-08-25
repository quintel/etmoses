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

        $(this.formField).text(JSON.stringify(multiTableData));

        this.tables.forEach(function (table) {
            if (table.mergeCallback) {
                table.mergeCallback();
            }
        });
    }

    function afterAppendCallback() {
        this.tables.forEach(function (table) {
            if (table.afterAppendCallback) {
                table.afterAppendCallback();
            }
        });
    }

    MultiTable.prototype = {
        append: function () {
            this.tables.forEach(function (table) {
                table.editableTable.append(mergeAndUpdate.bind(this));
            }.bind(this));

            afterAppendCallback.call(this);
        }
    }

    function MultiTable(scope) {
        this.scope = scope;
    }

    return MultiTable;
}());

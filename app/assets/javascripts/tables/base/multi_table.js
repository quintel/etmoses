var MultiTable = (function () {
    'use strict';

    function getData() {
        var result = [];

        this.tables.forEach(function (table) {
            result = result.concat(table.getData());
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
                table.setProfiles();
            }
        });
    }

    MultiTable.prototype = {
        append: function () {
            this.tables.forEach(function (table) {
                table.append(mergeAndUpdate.bind(this));
            }.bind(this));

            afterAppendCallback.call(this);
        }
    }

    function MultiTable(scope) {
        this.scope = scope;
    }

    return MultiTable;
}());

var MultiTable = (function () {
    'use strict';

    function resetProfiles() {
        this.tables.forEach(function (table) {
            table.setProfiles();
        });
    }

    function getData() {
        var result = [];

        this.tables.forEach(function (table) {
            result = result.concat(table.editableTable.getData());
        });

        return result;
    }

    function mergeAndUpdate() {
        var multiTableData = getData.call(this);

        $("#heat_source_list_source_list").text(JSON.stringify(multiTableData));
        resetProfiles.call(this);
    }

    MultiTable.prototype = {
        add: function(table) {
            this.tables.push(table);

            table.editableTable.append(mergeAndUpdate.bind(this));
            table.setProfiles();
        }
    }

    function MultiTable() {
        this.tables = [];
    }

    return MultiTable;
}());

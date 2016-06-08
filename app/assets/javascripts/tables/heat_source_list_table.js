var HeatSourceListTable = (function () {
    'use strict';

    function resetProfiles() {
        this.tables.forEach(function (table) {
            table.setProfiles();
        });
    }

    HeatSourceListTable.prototype = {
        add: function(table) {
            this.multiTable.add(table);

            table.setProfiles();
        }
    }

    function HeatSourceListTable() {
        this.multiTable = new MultiTable(
            "#heat_source_list_asset_list", resetProfiles);
    }

    return HeatSourceListTable;
}());

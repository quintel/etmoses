var HeatAssetListTable = (function () {
    'use strict';

    HeatAssetListTable.prototype = {
        add: function(table) {
            this.multiTable.add(table);

            table.append();
        }
    }

    function HeatAssetListTable() {
        this.multiTable = new MultiTable("#heat_asset_list_asset_list");
    }

    return HeatAssetListTable;
}());

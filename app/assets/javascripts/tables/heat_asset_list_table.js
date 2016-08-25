var HeatAssetListTable = (function () {
    'use strict';

    HeatAssetListTable.prototype = $.extend({}, MultiTable.prototype);

    function HeatAssetListTable(selector) {
        MultiTable.call(this, selector);

        this.formField = "#heat_asset_asset_list";
        this.tables    = [
            new HeatAssetListTablePart("table.interactions.heat_asset_list.primary"),
            new HeatAssetListTablePart("table.interactions.heat_asset_list.secondary")
        ];
    }

    return HeatAssetListTable;
}());

var HeatAssetListTable = (function () {
    'use strict';

    HeatAssetListTable.prototype = $.extend({}, MultiTable.prototype);

    function HeatAssetListTable(selector) {
        MultiTable.call(this, selector);

        this.formField = "#heat_asset_list_asset_list";
        this.tables    = [
            new HeatAssetListPrimaryTable("table.interactions.heat_asset_list.primary"),
            new HeatAssetListSecondaryTable("table.interactions.heat_asset_list.secondary")
        ];
    }

    return HeatAssetListTable;
}());

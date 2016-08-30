var HeatSourceListTable = (function () {
    'use strict';

    HeatSourceListTable.prototype = $.extend({}, MultiTable.prototype, {});

    function HeatSourceListTable(selector) {
        MultiTable.call(this, selector);

        this.formField = "#heat_source_list_asset_list";
        this.tables    = [
            new HeatSourceListDispatchable("table.interactions.heat_source_list.dispatchable"),
            new HeatSourceListMustRun("table.interactions.heat_source_list.must_run")
        ];
    }

    return HeatSourceListTable;
}());

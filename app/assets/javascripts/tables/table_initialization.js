/*globals GasAssetListTable,HeatAssetListTable,HeatAssetListTablePart,
HeatSourceListTable,HeatSourceListTablePart,MarketModelTable*/

var TableInitializer = (function () {
    'use strict';

    var tables = {
            market_model_table:     MarketModelTable,
            gas_asset_list_table:   GasAssetListTable,
            heat_source_list_table: HeatSourceListTable,
            heat_asset_list_table:  HeatAssetListTable
        };

    return {
        initialize: function () {
            var i = new Date().getTime();

            $(this).attr("id", "table-" + i);

            var tableType     = $(this).data('type'),
                variableTable = ("current_"  + tableType).camelize();

            if (!tableType) { throw "Can't have a table without a type"; }

            window[variableTable] = new tables[tableType]("#table-" + i);
            window[variableTable].append();
        }
    };
}());

$(document).on("page:change", function () {
    'use strict';

    $(".table.single.interactions, .multi-table").each(TableInitializer.initialize);
});

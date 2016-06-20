/*globals GasAssetListTable,HeatAssetListTable,HeatAssetListTablePart,
HeatSourceListTable,HeatSourceListTablePart,MarketModelTable*/

var TableInitializer = (function () {
    'use strict';

    var tables = {
            market_model_table:          MarketModelTable,
            gas_asset_list_table:        GasAssetListTable,
            heat_source_list_table:      HeatSourceListTable,
            heat_asset_list_table:       HeatAssetListTable,
            part_heat_source_list_table: HeatSourceListTablePart,
            part_heat_asset_list_table:  HeatAssetListTablePart
        };

    function createMultiTable(tableName, tableType, id) {
        var table = new tables["part_" + tableType](id);

        if (window[tableName]) {
            window[tableName].add(table);
        } else {
            window[tableName] = new tables[tableType](id);
            window[tableName].add(table);
        }
    }

    return {
        initialize: function (i) {
            $(this).attr("id", "table-" + i);

            var tableType     = $(this).data('type'),
                multiTable    = $(this).hasClass("multi_table"),
                variableTable = ("current_"  + tableType).camelize();

            if (!tableType) { return false; }

            if (multiTable) {
                createMultiTable(variableTable, tableType, "#table-" + i);
            } else {
                window[variableTable] = new tables[tableType]("#table-" + i);
                window[variableTable].append();
            }
        }
    };
}());

$(document).on("page:change", function () {
    'use strict';

    $(".table.interactions").each(TableInitializer.initialize);
});

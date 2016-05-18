var TableInitializer = (function() {
    'use strict';

    var tables = {
        market_model_table:     MarketModelTable,
        gas_asset_list_table:   GasAssetListTable,
        heat_source_list_table: HeatSourceListTable
    };

    function createMultiTable(tableName, table) {
        if (window[tableName]) {
            window[tableName].add(table);
        } else {
            window[tableName] = new MultiTable();
            window[tableName].add(table);
        }
    }

    return {
        initialize: function(i) {
            $(this).attr("id", "table-" + i);

            var tableType     = $(this).data('type'),
                multiTable    = $(this).hasClass("multi_table"),
                variableTable = ("current_"  + tableType).camelize(),
                newTable      = new tables[tableType]("#table-" + i);

            if (multiTable) {
                createMultiTable(variableTable, newTable);
            } else {
                window[variableTable] = newTable;
                window[variableTable].append();
            }
        }
    };
}());

$(document).on("page:change", function () {
    'use strict';

    $(".table.interactions").each(TableInitializer.initialize);
});

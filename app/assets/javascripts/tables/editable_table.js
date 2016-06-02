/*globals GasAssetListTable,MarketModelTable*/

var EditableTable = (function () {
    'use strict';

    function extractTextfromCells(row) {
        return $(row).find("td.editable").toArray().map(function (cell) {
            var value;
            if ($(cell).find("select:visible").length > 0) {
                value = $.trim($(cell).find("select").val());
            } else {
                value = $.trim($(cell).find("input").val());
            }
            return value;
        });
    }

    function tableRows() {
        return $(this.selector).find("tbody tr:not(.blank)")
            .toArray().map(extractTextfromCells);
    }

    function tableHeader(index) {
        return $($(this.selector).find("thead th")[index]).data("header");
    }

    function rowToTechnologyObject(tableRow) {
        var tableData = {},
            self = this;

        $.each(tableRow, function (i, attribute) {
            var header = tableHeader.call(self, i);
            tableData[header] = attribute;

            this.changeData.call({
                attribute: attribute,
                header: header,
                tableData: tableData
            });
        }.bind(this));

        return tableData;
    }

    function tableToProfile() {
        var self = this;
        return tableRows.call(this).map(function (tableRow) {
            return rowToTechnologyObject.call(self, tableRow);
        });
    }

    function addClickListenersToAddRow() {
        $(this.selector).find("a.add-row").on("click", function (e) {
            e.preventDefault();

            var row             = $(e.currentTarget).parents("tr"),
                clonedRow       = row.clone(true, true).removeClass("blank"),
                originalSelects = row.find('select'),
                clonedSelects;

            if (originalSelects.length) {
                clonedSelects = clonedRow.find('select');

                originalSelects.each(function(index, element) {
                    $(clonedSelects[index]).val($(element).val());
                });
            }

            clonedRow.insertAfter(row);
            this.changeListener();
        }.bind(this));
    }

    function addClickListenersToDeleteRow() {
        $(this.selector).find("a.remove-row").on("click", function (e) {
            e.preventDefault();

            $(e.currentTarget).parents("tr").remove();
            this.changeListener();
        }.bind(this));
    }

    EditableTable.prototype = {
        append: function (changeListener, changeData) {
            this.changeListener = (changeListener || function () { return; });
            this.changeData = (changeData || function () { return; });

            $(this.selector).on('change', this.changeListener.bind(this));

            addClickListenersToAddRow.call(this);
            addClickListenersToDeleteRow.call(this);
        },

        getData: function () {
            return tableToProfile.call(this);
        }
    };

    function EditableTable(selector) {
        this.selector       = selector;
        this.changeListener = function () { return; };
        this.changeData     = function () { return; };
    }

    return EditableTable;
}());

$(document).on("page:change", function () {
    'use strict';

    var tableType, tableClass, variableTable,
        tables = {
            market_model_table:   MarketModelTable,
            gas_asset_list_table: GasAssetListTable
        };

    $("table.table.interactions").each(function () {
        tableType     = $(this).data('type');
        tableClass    = $(this).attr('class').replace(/\s/g, '.');
        variableTable = ("current_"  + tableType).camelize();

        window[variableTable] = new tables[tableType](tableClass);
        window[variableTable].append();
    });
});

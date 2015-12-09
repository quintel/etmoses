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
        return $(this.selector).find("tbody tr").toArray().map(extractTextfromCells);
    }

    function tableHeader(index) {
        return $(this.selector).find("thead th").get(index).getAttribute("data-header");
    }

    function rowToTechnologyObject(tableRow) {
        var tableData = {},
            self = this;

        for (var i = 0; i < tableRow.length; i++) {
            var attribute = tableRow[i],
                header = tableHeader.call(self, i);

            tableData[header] = attribute;

            this.changeData.call({
                attribute: attribute,
                header: header,
                tableData: tableData
            });
        }

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

            var row       = $(e.currentTarget).parents("tr"),
                clonedRow = row.clone(true, true);

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

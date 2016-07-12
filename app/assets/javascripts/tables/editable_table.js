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

    function addRow(e) {
        e.preventDefault();

        var row             = $(e.currentTarget).parents("tr"),
            clonedRow       = row.clone(true, true).removeClass("blank"),
            originalSelects = row.find('select'),
            clonedSelects;

        $(this.selector).find("tbody tr:not(.blank)").removeAttr("class");

        if (originalSelects.length) {
            clonedSelects = clonedRow.find('select');

            originalSelects.each(function(index, element) {
                $(clonedSelects[index]).val($(element).val());
            });
        }

        clonedRow.addClass("new");
        clonedRow.insertAfter(row);
        this.changeListener();

        hideLastRow.call(this);
    }

    function addClickListenersToAddRow() {
        $(this.selector)
            .find("a.add-row")
            .off('click')
            .on('click', addRow.bind(this));
    }

    function addClickListenersToDeleteRow() {
        $(this.selector)
            .find("a.remove-row")
            .off('click')
            .on('click', function (e) {
                e.preventDefault();

                $(e.currentTarget).parents("tr").remove();
                this.changeListener();
            }.bind(this));
    }

    function hideLastRow() {
        /* Remove the last remove-row button because a user should
         * not be able to remove the last row of a table. */
        $(this.selector).find("a.remove-row").show();

        $(this.selector)
            .find("tr:last-child")
            .find("a.remove-row").hide();
    }

    EditableTable.prototype = {
        append: function (changeListener, changeData) {
            this.changeListener = (changeListener || function () { return; });
            this.changeData = (changeData || function () { return; });

            $(this.selector)
                .off('change')
                .on('change', this.changeListener.bind(this));

            addClickListenersToAddRow.call(this);
            addClickListenersToDeleteRow.call(this);
            hideLastRow.call(this);
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

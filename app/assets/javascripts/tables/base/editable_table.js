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
            originalSelects = row.find('select'),
            clonedRow,
            clonedSelects;

        if (this.beforeRowAddedListener) {
            this.beforeRowAddedListener();
        }

        clonedRow = row.clone(true, true).removeClass("blank");

        if (originalSelects.length) {
            clonedSelects = clonedRow.find('select');

            originalSelects.each(function(index, element) {
                $(clonedSelects[index]).val($(element).val());
            });
        }

        clonedRow.insertAfter(row);

        if (this.rowAddedListener) {
            this.rowAddedListener(clonedRow);
        }

        this.changeListener();
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
                var row =  $(e.currentTarget).parents("tr");

                e.preventDefault();

                if (this.beforeRowDeletedListener) {
                    this.beforeRowDeletedListener(row)
                }

                row.remove();

                if (this.rowDeletedListener) {
                    this.rowDeletedListener(row)
                }

                this.changeListener();
            }.bind(this));
    }

    function markAsEditable() {
        var pane = $(this.selector).parents(".tab-pane"),
            form = pane.find("form");

        $("ul.nav li a[href=#" + pane.attr("id") + "]")
            .add(form)
            .addClass("editing");
    }

    EditableTable.prototype = {
        append: function (changeListener, changeData) {
            this.changeListener = (changeListener || function () { return; });
            this.changeData = (changeData || function () { return; });

            $(this.selector)
                .off('change.table')
                .on('change.table', function() {
                    if (! this.suspended) {
                        this.changeListener.call(this)
                    } else {
                        this.updatedDuringSuspend = true;
                    }
                }.bind(this));

            $(this.selector)
                .off('change.editable')
                .on('change.editable', markAsEditable.bind(this));

            addClickListenersToAddRow.call(this);
            addClickListenersToDeleteRow.call(this);
        },

        getData: function () {
            return tableToProfile.call(this);
        },

        /**
         * Instructs the table to stop firing the changeListener whenever a
         * change occurs in the table.
         */
        suspendUpdates: function () {
            if (! this.suspended) {
                this.updatedDuringSuspend = false;
            }

            this.suspended = true;
        },

        /**
         * Resumes handling updates by firing the changeListener when changes
         * occur in the table. If any updates occurred while the table was
         * suspended the changeListener will be invoked to handle the changes.
         */
        resumeUpdates: function () {
            this.suspended = false;

            if (this.updatedDuringSuspend) {
                this.changeListener.call(this);
            }

        }
    };

    function EditableTable(selector) {
        this.selector       = selector;
        this.changeListener = function () { return; };
        this.changeData     = function () { return; };

        this.suspended            = false;
        this.updatedDuringSuspend = false;
    }

    return EditableTable;
}());

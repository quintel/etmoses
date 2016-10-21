/*globals GasAssetListTable,MarketModelTable*/

/* EditableTable class
 *
 * The EditableTable is used for all <table> elements which have the
 * class '.interactions'. The table contains rows that can be added and
 * removed with the respected '+' and 'x' icons.
 *
 * The <tfoot> of the <table> contains the template of the newly added
 * table row.
 *
 */

var EditableTable = (function () {
    'use strict';

    /* Callback for profile selector
     * Whenever somebody select's a different heat asset the data from that
     * select option will be parsed over the table row and the values set
     * in their respectable inputs and select boxes.
     */
    function updateRows(technology) {
        var technology = $(this.target).find("select.key"),
            techData   = $(technology).selectedOption().data();

        for (var key in techData) {
            $(this.target)
                .find(".editable." + key.underscorize())
                .find("input, select")
                .val(techData[key]);
        }
    }

    function extractTextfromCells(row) {
        return $(row).find("td.editable").toArray().map(function (cell) {
            var input = $(cell).find("select:visible").length > 0 ? 'select' : 'input';

            return  $(cell).find(input).rawValue();
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

        var row             = $(this.selector).find("tfoot tr"),
            originalSelects = row.find('select'),
            clonedRow,
            clonedSelects;

        if (this.beforeRowAddedListener) {
            this.beforeRowAddedListener();
        }

        clonedRow = row.clone(true, true);

        if (originalSelects.length) {
            clonedSelects = clonedRow.find('select');

            originalSelects.each(function(index, element) {
                $(clonedSelects[index]).val($(element).val());
            });
        }

        $(this.selector).find("tbody").append(clonedRow);

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

    function removeRow(e) {
        var row =  $(e.currentTarget).parents("tr");

        e.preventDefault();

        if (this.beforeRowDeletedListener) {
            this.beforeRowDeletedListener(row)
        }

        row.remove();

        if (this.rowDeletedListener) {
            this.rowDeletedListener(row)
        }

        if (this.count() < 1) {
            this.emptyButton.removeClass("hidden");

            $(this.selector).find("thead").addClass("hidden");
        }

        this.changeListener();
    }

    function addClickListenersToDeleteRow() {
        $(this.selector)
            .find("a.remove-row")
            .off('click')
            .on('click', removeRow.bind(this));
    }

    function markAsEditable() {
        var pane = $(this.selector).parents(".tab-pane"),
            form = pane.find("form");

        $("ul.nav li a[href=#" + pane.attr("id") + "]")
            .add(form)
            .addClass("editing");
    }

    function enableLastRow(e) {
        $(this.selector).find("thead").removeClass("hidden");

        addRow.call(this, e);

        this.emptyButton.addClass("hidden");
        this.changeListener();

        if (this.afterAppendCallback) {
            this.afterAppendCallback();
        }
    }

    EditableTable.prototype = {
        append: function (changeListener, changeData) {
            this.changeListener = (changeListener || function () { return; });
            this.changeData = (changeData || function () { return; });

            new Rounder($(this.selector)[0]).initialize();

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

            this.emptyButton
                .off("click")
                .on("click", enableLastRow.bind(this));

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

        },

        setProfiles: function () {
            $(this.selector).find("tr:not(.blank)").each(function() {
                new ProfileSelectBox(this).add(updateRows);
            });
        },

        count: function () {
            return tableRows.call(this).length;
        }
    };

    function EditableTable(selector) {
        this.selector             = selector;
        this.changeListener       = function () { return; };
        this.changeData           = function () { return; };
        this.emptyButton          = $(this.selector).prev(".empty-button")

        this.suspended            = false;
        this.updatedDuringSuspend = false;
    }

    return EditableTable;
}());

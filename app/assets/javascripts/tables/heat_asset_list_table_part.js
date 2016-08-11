/*globals EditableTable*/

var HeatAssetListTablePart = (function () {
    'use strict';

    var editableTable;

    /* Callback for profile selector
     * Whenever somebody select's a different heat asset the data from that
     * select option will be parsed over the table row and the values set
     * in their respectable inputs and select boxes.
     */
    function updateRows(technology) {
        var technology = $(this.target).find("select.key"),
            techData   = $(technology)
                            .find("option[value=" + technology.val() + "]")
                            .data();

        for (var key in techData) {
            $(this.target)
                .find(".editable." + key.underscorize())
                .find("input, select")
                .val(techData[key]);
        }
    }

    /**
     * Given a selector for a table part, creates sliders for each of the
     * connection distribution fields and links them such that they sum to 1.0.
     */
    function createSliders(table, connections) {
        var sliderInputs =
            $(table.selector)
                .find('tbody tr:not(.blank)')
                .find('input[name=connection_distribution]');

        if (sliderInputs.length) {
            sliderInputs.on('change', function(e) {
                $(e.target).closest('td').find('.value').text(
                    distributionLabel(e.value.newValue, connections)
                )
            });

            sliderInputs.each(function (index, el) {
                var $el = $(el);

                // The bootstrap slider wants the value provided with
                // data-slider-value, which is not updated when the user makes
                // changes. This results in sliders snapping back to their
                // original values when adding or removing new sliders.
                //
                // Instead, get the value from the input.
                $el.slider({ tooltip: 'hide', value: parseFloat($el.val()) });

                if (sliderInputs.length === 1) {
                    $el.slider('disable');
                    $el.slider('setValue', 1.0, true, true);
                }
            });

            // Suspend updates of the editable table while dragging a slider.
            // This improves performance substantially and prevents incorrect
            // values from being saved by "linkedSliders" change events
            // triggering too early.
            sliderInputs.on('slideStart', function() {
                table.suspendUpdates()
            });

            sliderInputs.on('slideStop', function() {
                table.resumeUpdates()
            });

            sliderInputs.linkedSliders({ total: 1.0 });
        }
    }

    /**
     * Given a selector for a table part, removes the linkedSliders plugin from
     * each connection distribution field and them removes the sliders.
     */
    function destroySliders(selector) {
        var sliders = $(selector).find('tbody tr:not(.blank) input.slider');

        $.linkedSliders._destroyPlugin(sliders);
        sliders.slider('destroy');
    }

    /**
     * Creates the label to be shown next to a connection distribution slider.
     */
    function distributionLabel(value, connections) {
        return '' + Math.round(value * 100) + '% ' +
            '(' + Math.round(connections * value) + ' connections)';
    }

    HeatAssetListTablePart.prototype = {
        append: function () {
            this.setProfiles();

            createSliders(this.editableTable, this.connections);
        },

        setProfiles: function () {
            $(this.editableTable.selector).find("tr:not(.blank)").each(function() {
                new ProfileSelectBox(this).add(updateRows);
            });
        }
    };

    function createSliderForRow(row) {
        $(row).find('input.slider')
            .val('0.0')
            .attr('data', 'value: 0.0')
            .attr('data-slider-value', '0.0');

        $(row).find('.value').text(distributionLabel(0, 0));

        createSliders(this.editableTable, this.connections);
    }

    function rowAddedListener(row) {
        this.setProfiles();

        createSliderForRow.call(this, row);
    }

    function HeatAssetListTablePart(selector) {
        this.editableTable = new EditableTable(selector);
        this.connections   = parseInt($(selector).data('connections'), 10);

        this.editableTable.beforeRowAddedListener =
            destroySliders.bind(this, this.editableTable.selector);

        this.editableTable.rowAddedListener =
            rowAddedListener.bind(this);

        this.editableTable.beforeRowDeletedListener =
            this.editableTable.beforeRowAddedListener;

        this.editableTable.rowDeletedListener =
            this.editableTable.rowAddedListener;
    }

    return HeatAssetListTablePart;
}());

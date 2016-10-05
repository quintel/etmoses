/*globals EditableTable*/

var HeatAssetListTablePart = (function () {
    'use strict';

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
    function destroySliders() {
        var sliders = $(this.selector).find('tbody tr:not(.blank) input.slider');

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

    HeatAssetListTablePart.prototype = $.extend({}, EditableTable.prototype, {
        afterAppendCallback: function () {
            createSliders(this, this.connections);
        }
    });

    function createSliderForRow(row) {
        $(row).find('input.slider')
            .val('0.0')
            .attr('data', 'value: 0.0')
            .attr('data-slider-value', '0.0');

        $(row).find('.value').text(distributionLabel(0, 0));

        createSliders(this, this.connections);
    }

    function rowAddedListener(row) {
        this.setProfiles();

        createSliderForRow.call(this, row);
    }

    function HeatAssetListTablePart(selector) {
        EditableTable.call(this, selector);

        this.connections   = parseInt($(selector).data('connections'), 10);

        this.beforeRowAddedListener   = destroySliders.bind(this);
        this.rowAddedListener         = rowAddedListener.bind(this);
        this.beforeRowDeletedListener = this.beforeRowAddedListener;
        this.rowDeletedListener       = this.rowAddedListener;
    }

    return HeatAssetListTablePart;
}());

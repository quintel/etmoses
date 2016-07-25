/*globals Ajax,D3LoadChart,Quantity,TransformerInitializer*/

var D3BaseStaticLoadChart = (function () {
    "use strict";

    var spinner;

    D3BaseStaticLoadChart.prototype = $.extend({}, D3LoadChart.prototype, {
        draw: function (currentWeek, loadFirstTime) {
            var week      = (currentWeek || 1),
                firstTime = (loadFirstTime !== false),
                params    = {
                    calculation: {
                        range_start: (week - 1) * 672,
                        range_end:   week * 672,
                        resolution:  'high'
                    }
                };

            spinner = this.holder().find('.loading-spinner');
            spinner.addClass('on');

            Ajax.json(this.settings.url, params, function (data) {
                this.settings.load = TransformerInitializer
                    .initialize(this.settings)
                    .transform(data);

                spinner.removeClass('on');

                if (firstTime) {
                    D3LoadChart.prototype.render.call(this, data);
                } else {
                    D3LoadChart.prototype.update.call(this, data);
                }
            }.bind(this));
        },

        getScaling: function (load) {
            return new Quantity(this.maxYvalue(load), 'kW').smartScale();
        }
    });

    function D3BaseStaticLoadChart(chartClass, settings) {
        D3LoadChart.call(this, chartClass);

        this.settings      = settings || {};
        this.seriesOpacity = 1.0;
        this.height        = 400;
        this.width         = this.holder().innerWidth();
        this.settings.dateCallback = this.draw.bind(this);
    }

    return D3BaseStaticLoadChart;
}());

/*globals Ajax,D3LoadChart,Quantity,TransformerInitializer*/

var D3BaseStaticLoadChart = (function () {
    "use strict";

    function drawChart(params, firstTime) {
        Ajax.json(this.settings.url, params, function (data) {
            this.settings.load = TransformerInitializer
                .initialize(this.settings)
                .transform(data);

            this.spinner.removeClass('on');

            firstTime ? this.render(data) : this.update(data);
        }.bind(this));
    }

    D3BaseStaticLoadChart.prototype = $.extend({}, D3LoadChart.prototype, {
        draw: function (currentWeek, loadFirstTime) {
            var week   = (currentWeek || 1),
                params = {
                    calculation: {
                        range_start: (week - 1) * 672,
                        range_end:   week * 672,
                        resolution:  'high'
                    }
                };

            this.spinner = this.holder().find('.loading-spinner');
            this.spinner.addClass('on');

            drawChart.call(this, params, (loadFirstTime !== false));
        }
    });

    function D3BaseStaticLoadChart(chartClass, settings) {
        D3LoadChart.call(this, chartClass);

        this.settings              = settings || {};
        this.seriesOpacity         = 1.0;
        this.height                = 400;
        this.width                 = this.holder().innerWidth();
        this.settings.dateCallback = this.draw.bind(this);
        this.axisLabel             = this.settings.axis_label;
    }

    return D3BaseStaticLoadChart;
}());

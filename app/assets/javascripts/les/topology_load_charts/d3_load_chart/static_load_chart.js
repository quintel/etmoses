var StaticLoadChart = (function () {
    "use strict";

    var spinner;

    function fetchAndRenderWeek(week, firstTime) {
        var params = {
            calculation: {
                range_start: (week - 1) * 672,
                range_end:   week * 672,
                resolution:  'high'
            }
        }

        spinner = $(this.chartClass).parents('.chart-holder')
            .find('.loading-spinner');

        spinner.addClass('on');

        Ajax.json(this.settings.url, params, function (data) {
            this.settings.load = TransformatorInitializer
                .initialize(this.settings)
                .transform(data);

            spinner.removeClass('on');

            if (firstTime) {
                D3LoadChart.prototype.render.call(this, data);
            } else {
                D3LoadChart.prototype.update.call(this, data);
            }
        }.bind(this));
    }

    StaticLoadChart.prototype = Object.create(D3LoadChart.prototype, {
        draw: {
            value: function () {
                fetchAndRenderWeek.call(this, 1, true);
            }
        }
    });

    function StaticLoadChart(chartClass, settings) {
        this.chartClass    = chartClass;
        this.settings      = settings;
        this.width         = 500;
        this.height        = 500;
        this.seriesOpacity = 1.0;

        this.staticSettings = {
            dateCallback: fetchAndRenderWeek.bind(this)
        };
    }

    StaticLoadChart.prototype.constructor = StaticLoadChart;

    return StaticLoadChart;
}());

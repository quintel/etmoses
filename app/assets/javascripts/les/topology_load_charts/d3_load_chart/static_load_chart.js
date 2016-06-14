var StaticLoadChart = (function () {
    "use strict";

    var spinner;

    StaticLoadChart.prototype = Object.create(D3LoadChart.prototype, {
        draw: {
            value: function () {
                spinner = $(this.chartClass).parents('.chart-holder')
                              .find('.loading-spinner');

                spinner.show();

                Ajax.json(this.settings.url, { }, function (data) {
                    this.settings.load = StaticTransformator.transform(data);

                    spinner.hide();

                    D3LoadChart.prototype.render.call(this, data);
                }.bind(this));
            }
        }
    });

    function StaticLoadChart(chartClass, settings) {
        this.chartClass = chartClass;
        this.settings   = settings;
        this.width      = 500;
        this.height     = 500;
    }

    StaticLoadChart.prototype.constructor = StaticLoadChart;

    return StaticLoadChart;
}());

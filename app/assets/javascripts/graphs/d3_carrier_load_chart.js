var D3CarrierLoadChart = (function () {
    'use strict';

    D3CarrierLoadChart.prototype = $.extend({}, D3LoadChart.prototype, {
        emptyMessage: function () {
            return $(this.chartClass).parent().find(".empty");
        },

        chartDataCallback: function (chartData) {
            if (chartData) {
                $(this.chartClass).removeClass("hidden");
                this.emptyMessage().addClass("hidden");
            } else {
                this.displayEmptyMessage(this.lastRequestedData.name);
            }
        },

        displayEmptyMessage: function (name) {
            var context,
                empty   = this.emptyMessage(),
                carrier = {
                    gas: "gas",
                    load: "electricity",
                    heat: "heat"
                }[this.settings.view_carrier];

            $(this.chartClass).addClass("hidden");

            context = (this.settings.view_as === 'total') ? "total" : carrier;

            empty.removeClass("hidden");
            empty.find("span.context").text(context);
            empty.find("span.node").text(name);
        }
    });

    function D3CarrierLoadChart(chartClass, curveType, settings) {
        D3LoadChart.call(this, chartClass, curveType, settings);
    };

    return D3CarrierLoadChart;
}());

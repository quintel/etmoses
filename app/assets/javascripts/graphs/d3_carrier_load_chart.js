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
            var carrier,
                empty   = this.emptyMessage(),
                context = empty.find("span.context");

            if (this.settings.view_as === 'total') {
                context.text("");
            } else {
                carrier = this.settings.view_carrier.replace(/_[a-z]+$/, '');

                context.text(I18n.t("carriers." + carrier).toLowerCase());
            }

            empty.find("span.node").text(name);

            $(this.chartClass).addClass("hidden");
            empty.removeClass("hidden");
        }
    });

    function D3CarrierLoadChart(chartClass, curveType, settings) {
        D3LoadChart.call(this, chartClass, curveType, settings);
    };

    return D3CarrierLoadChart;
}());

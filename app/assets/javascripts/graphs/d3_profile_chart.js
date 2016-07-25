/*globals D3LoadChart */

var D3ProfileChart = (function () {
    "use strict";

    function loadChartData(week) {
        return[ {
            type: this.settings.curve_type,
            name: this.profile.name || this.profile.key,
            values: { total: LoadSlicer.slice(this.profile.values, week) },
            area: true
        } ];
    }

    function render(profile) {
        $(this.context).empty();

        this.profile = profile;

        $.extend(this.settings, {
            resolution:    'high',
            load:          loadChartData.call(this, 1),
            dateCallback:  this.dateCallback.bind(this)
        });

        this.render(this.settings.load[0]);
    }

    D3ProfileChart.prototype = $.extend({}, D3BaseStaticLoadChart.prototype, {
        getScaling: function () {
            return false;
        },

        axisLabel: function () {
            return LoadChartsSettings[this.settings.curve_type].axisLabel;
        },

        dateCallback: function (week) {
            this.settings.load = loadChartData.call(this, week);

            this.update();
        },

        draw: function () {
            $.getJSON(this.settings.url).success(render.bind(this));
        }
    });

    function D3ProfileChart(chartClass, settings) {
        D3BaseStaticLoadChart.call(this, chartClass, settings);

        this.width = 1080;
    }

    return D3ProfileChart;
}());

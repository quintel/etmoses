var LoadChartHelper = (function () {
    'use strict';

    return {
        globalBrushExtent: undefined,
        currentWeek: undefined,
        forceReload: false,
        disableCapacity: true,
        charts: [],

        toggleCapacity: function (currentChartId) {
            var currentChart = this.charts[currentChartId - 1],
                d3Chart      = d3.select(".chart-id-" + currentChartId + " svg"),
                d3ChartData  = d3Chart.data();

            if (d3ChartData[0]) {
                d3ChartData[0][d3ChartData[0].length - 1].disabled = this.disableCapacity;
            }

            currentChart.update();
        },

        updateBrush: function (currentChartId) {
            if (window.localSettings !== undefined) {
                this.globalBrushExtent = window.localSettings.get('global_brush_extent');
            }

            if (this.globalBrushExtent) {
                this.setBrushExtent();
                this.reloadChart(currentChartId);
            }
        },

        reloadChart: function (currentChartId) {
            var currentChart = this.charts[currentChartId - 1];
            if (currentChart && currentChart.update) {
                currentChart.update();
            }
        },

        setBrushExtent: function () {
            this.charts.forEach(function (chart) {
                if (chart) {
                    chart.brushExtent(this.globalBrushExtent);
                }
            });
        },

        clearBrush: function () {
            this.globalBrushExtent = undefined;
            window.localSettings.remove('global_brush_extent');
            this.charts.forEach(function (chart) {
                if (chart) {
                    d3.select(".brush").call(chart.brush.clear());
                    chart.brushExtent([0, 0]);
                    chart.update();
                }
            });
        },

        formatDate: function (date) {
            var monthNames = [
                "January", "February", "March",
                "April", "May", "June", "July",
                "August", "September", "October",
                "November", "December"
            ];

            return [date.getDate(), monthNames[date.getMonth()]].join(" ");
        }
    };
}());

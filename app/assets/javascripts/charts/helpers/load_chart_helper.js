var LoadChartHelper = (function () {
    'use strict';

    return {
        globalBrushExtent: undefined,
        currentWeek: undefined,
        forceReload: false,
        charts: [],

        toggleCapacity: function (currentChartId) {
            var currentChart = this.charts[currentChartId - 1],
                d3Chart      = d3.select(".chart-id-" + currentChartId + " svg"),
                d3ChartData  = d3Chart.data();

            if (d3ChartData[0]) {
                d3ChartData[0].forEach(function (chart) {
                    chart.disabled = !LoadChartsSettings[chart.type].enabled;
                }.bind(this));
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
            }.bind(this));
        },

        clearBrush: function () {
            if (window.localSettings !== undefined) {
                window.localSettings.remove('global_brush_extent');
            }

            this.globalBrushExtent = undefined;
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

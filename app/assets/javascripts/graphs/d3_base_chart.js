var D3BaseChart = (function () {
    'use strict';

    D3BaseChart.prototype = {
        draw: function () {
            throw "Every chart that inherits from D3Chart needs to implement draw method";
        },

        reload: function () {
            throw "Every chart that inherits from D3Chart needs to implement reload method";
        },

        holder: function () {
            return $(this.chartClass).parents(".chart-holder");
        }
    };

    function D3BaseChart(chartClass) {
        this.chartClass = chartClass;
    }

    return D3BaseChart;
}());

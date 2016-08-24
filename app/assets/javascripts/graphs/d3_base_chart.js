var D3BaseChart = (function () {
    'use strict';

    D3BaseChart.prototype = {
        position: function () {
            return [this.margin.left, this.margin.top].join(",");
        },

        drawBaseSVG: function () {
            var width   = (this.width + this.margin.left + this.margin.right),
                height  = (this.height + this.margin.top + this.margin.bottom + this.height2);

            return d3.select(this.chartClass).append("svg")
                .attr("width",  width)
                .attr("height", height)
                .append("g")
                .attr("transform", "translate(" + this.position() + ")");
        },

        draw: function () {
            throw "Every chart that inherits from D3BaseChart needs to implement draw method";
        },

        reload: function () {
            throw "Every chart that inherits from D3BaseChart needs to implement reload method";
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

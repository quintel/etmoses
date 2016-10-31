/*globals ChartSettings*/

var Legend = (function () {
    'use strict';

    function setColor(d) {
        return d.visible ? d.areaColor : "#F1F1F2";
    }

    function onLegendClick(d) {
        if (this.d3Chart.settings.view_as === 'stacked') { return false; }

        d.visible = !d.visible;

        ChartSettings.forChart(d.type).visible = d.visible;

        this.d3Chart.setYscaleDomain();

        d3.select(".legend-item." + d.type)
            .select(".square")
            .transition()
            .style("background-color", setColor);
    }

    function onLegendMouseOver(d) {
        d3.select(this)
            .select(".square")
            .transition()
            .style("background-color", function (d) {
                return d.areaColor;
            });

        d3.select(".line." + d.type)
            .transition()
            .style("stroke-width", 1.5);
    }

    function onLegendMouseOut(d) {
        d3.select(this)
            .select(".square")
            .transition()
            .style("background-color", setColor);

        d3.select(".line." + d.type)
            .transition()
            .style("stroke-width", 1.0);
    }

    Legend.prototype = {
        draw: function (data) {
            var legendItem, legendItemClass, sideClass;

            this.legend.selectAll(".legend-item").remove();
            legendItem = this.legend.selectAll(".legend-item").data(data);

            legendItemClass = "legend-item";
            sideClass       = (data.length > 3) ? "side" : "";

            legendItem.enter().append("span")
                .attr("class", function (d) {
                    return [
                        d.type,
                        legendItemClass,
                        sideClass
                    ].join(" ");
                })
                .on("click",     onLegendClick.bind(this))
                .on("mouseover", onLegendMouseOver)
                .on("mouseout",  onLegendMouseOut);

            legendItem.append("span")
                .attr("class", "square")
                .style("background-color", setColor);

            legendItem.append("span")
                .text(function (d) {
                    return d.key;
                });

            legendItem.exit().remove();
        }
    };

    function Legend(d3Chart) {
        this.d3Chart = d3Chart;
        this.legend  = d3Chart.legendDiv;
    }

    return Legend;
}());

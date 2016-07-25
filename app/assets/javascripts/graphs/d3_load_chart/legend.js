/*globals LoadChartsSettings*/

var Legend = (function () {
    'use strict';

    function onLegendClick(d) {
        if (this.d3Chart.settings.view_as === 'stacked') { return false; }

        d.visible = !d.visible;

        LoadChartsSettings[d.type].visible = d.visible;

        this.d3Chart.setYscaleDomain();

        d3.select(".legend-item." + d.type)
            .select(".square")
            .transition()
            .style("background-color", function (d) {
                return d.visible ? d.color : "#F1F1F2";
            });
    }

    function onLegendMouseOver(d) {
        d3.select(this)
            .select(".square")
            .transition()
            .style("background-color", function (d) {
                return d.color;
            });

        d3.select(".line." + d.type)
            .transition()
            .style("stroke-width", 1.5);
    }

    function onLegendMouseOut(d) {
        d3.select(this)
            .select(".square")
            .transition()
            .style("background-color", function (d) {
                return d.visible ? d.color : "#F1F1F2";
            });

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
                .style("background-color", function (d) {
                    return d.visible ? d.color : "#F1F1F2";
                });

            legendItem.append("span")
                .text(function (d) {
                    return d.key;
                });

            legendItem.exit().remove();
        }
    };

    function Legend(d3Chart, legend) {
        this.d3Chart = d3Chart;
        this.legend  = legend;
    }

    return Legend;
}());

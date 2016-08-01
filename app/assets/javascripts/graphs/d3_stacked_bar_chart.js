/*globals Ajax,Poller*/

var D3StackedBarGraph = (function () {
    'use strict';

    var chartKeys,
        spinner,
        margin = { top: 20, right: 160, bottom: 30, left: 80 },
        width  = 1135,
        height = 540 - margin.top - margin.bottom,

        x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1),
        y = d3.scale.linear().rangeRound([height, 0]),

        color = d3.scale.ordinal()
            .range(["#cde5f5", "#ef7676", "#5cc7bc", "#9b5191", "#f5e0b4"]),

        xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom"),

        yAxis = d3.svg.axis()
            .scale(y)
            .orient("left");

    function transformDataRow(d) {
        var posBase = 0,
            negBase = 0;

        d.stacked_transformed = [];

        chartKeys.forEach(function (s, index) {
            var v = {
                size: (Math.abs(d.stacked[s]) * 1000) / this.quantity.unit.power.multiple,
                y0: 0,
                index: index
            };

            if (d.stacked[s] > 0) {
                posBase += v.size;
                v.y0 = posBase;
            } else {
                v.y0 = negBase;
                negBase -= v.size;
            }

            d.stacked_transformed.push(v);
        }.bind(this));
    }

    function transformData(data) {
        data.forEach(transformDataRow.bind(this));

        data.extent = d3.extent(d3.merge(d3.merge(
            data.map(function (e) {
                return e.stacked_transformed.map(function (f) {
                    return [f.y0, f.y0 - f.size];
                });
            })
        )));
    }

    function drawD3Graph(data) {
        var state, legend, legendWrap;

        chartKeys = Object.keys(data[0].stacked);

        d3.select(this.chartClass).html('');

        this.quantity = new Quantity(this.maxYvalue(), this.unit).smartScale();
        this.unit     = this.quantity.unit.name;

        this.svg      = d3.select(this.chartClass).append("svg")
            .attr("width", width + margin.left)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        color.domain(data);

        transformData.call(this, data);

        x.domain(data.map(function (d) { return d.pressure_level; }));
        y.domain(data.extent);

        this.svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

        this.svg.append("g")
            .attr("class", "y axis")
            .call(yAxis)
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(this.unit);

        this.svg.append("line")
            .attr("class", "zero-line")
            .attr("x1", 0)
            .attr("x2", width)
            .attr("y1", y(0))
            .attr("y2", y(0));

        state = this.svg.selectAll(".state")
            .data(data)
            .enter().append("g")
            .attr("class", "g")
            .attr("transform", function (d) {
                return "translate(" + x(d.pressure_level) + ",0)";
            });

        state.selectAll("rect")
            .data(function (d) { return d.stacked_transformed; })
            .enter().append("rect")
            .attr("width", x.rangeBand() / 2)
            .attr("x", function () { return (x.rangeBand() / 4); })
            .attr("y", function (d) { return y(d.y0); })
            .attr("height", function (d) { return y(0) - y(d.size); })
            .style("fill", function (d) { return color(d.index); });

        legendWrap = d3.select(this.chartClass)
            .append("div")
            .attr("class", "legend-wrap");

        legend = legendWrap.selectAll(".legend")
            .data(chartKeys)
            .enter().append("span")
            .attr("class", "legend");

        legend.append("span")
            .attr("class", "square")
            .style("background-color", color);

        legend.append("span")
            .html(function (d) {
                return d;
            });

        spinner.hide();
    }

    function reloadD3Graph() {
        return;
    }

    function loadD3StackedGraph() {
        if (this.poll) {
            var self = this,
                poller;

            poller = new Poller({
                url:  this.url,
                data: { calculation: { resolution: 'high' } }
            });

            poller.poll().done(function (data) {
                    self.data = data;

                    drawD3Graph.call(self, data);
                })
                .fail(function () {
                    $(self.chartClass).html(
                        '<p class="chart-error">' +
                            '    Sorry, the chart could not be loaded.' +
                            '</p>'
                    );
                });
        } else {
            Ajax.json(this.url, {
                calculation: { resolution: 'high' }
            }, drawD3Graph.bind(this));
        }
    }

    D3StackedBarGraph.prototype = $.extend({}, D3BaseChart.prototype, {
        svg: null,
        line: null,
        maxYvalue: function () {
            return d3.max(this.data, function (row) {
                return d3.sum(chartKeys.map(function (key) {
                    return row.stacked[key];
                }));
            });
        },
        draw: function () {
            spinner = this.holder().find('.loading-spinner');

            spinner.show();
            loadD3StackedGraph.call(this);

            return this;
        },

        reload: function () {
            Ajax.json(this.url, {}, reloadD3Graph.bind(this));
        }
    });

    function D3StackedBarGraph(chartClass, data) {
        D3BaseChart.call(this, chartClass);

        this.url   = data.url;
        this.poll  = data.poll !== undefined;
        this.title = data.title;
        this.unit  = 'kWh';
    }

    return D3StackedBarGraph;
}());

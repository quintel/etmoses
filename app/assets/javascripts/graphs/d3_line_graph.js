/*globals Ajax*/

var D3LineGraph = (function () {
    'use strict';

    var margin = { top: 20, right: 20, bottom: 30, left: 70 },
        width  = 530 - margin.left - margin.right,
        height = 400 - margin.top - margin.bottom,
        x      = d3.time.scale().range([0, width]),
        y      = d3.scale.linear().range([height, 0]),
        xAxis  = d3.svg.axis().scale(x).orient("bottom"),
        yAxis  = d3.svg.axis().scale(y).orient("left");

    function convertData(data) {
        var key,
            conversed = [];

        for (key in data) {
            conversed.push({ y: data[key], x: new Date(key, 1, 1) });
        }

        return conversed;
    }

    function reloadD3Graph(rawData) {
        var data = convertData(rawData);

        x.domain(d3.extent(data, function (d) { return d.x; }));
        y.domain([0, d3.max(data, function (d) { return d.y; })]);

        this.svg.select("g .x.axis").call(xAxis);
        this.svg.select("g .y.axis").call(yAxis);

        this.svg.select("path.line").remove();
        this.svg.append("path")
            .datum(data)
            .attr("class", "line")
            .attr("d", this.line);
    }

    function drawD3Graph(rawData) {
        var data = convertData(rawData);

        this.line = d3.svg.line()
             .interpolate(this.interpolate)
             .x(function (d) { return x(d.x); })
             .y(function (d) { return y(d.y); });

        this.svg = d3.select(this.scope).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        x.domain(d3.extent(data, function (d) { return d.x; }));
        y.domain([0, d3.max(data, function (d) { return d.y; })]);

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
            .text(this.title);

        this.svg.append("path")
            .datum(data)
            .attr("class", "line")
            .attr("d", this.line);
    }

    D3LineGraph.prototype = {
        svg: null,
        line: null,
        draw: function () {
            Ajax.json(this.url, {}, drawD3Graph.bind(this));

            return this;
        },

        reload: function () {
            Ajax.json(this.url, {}, reloadD3Graph.bind(this));
        }
    };

    function D3LineGraph(scope, data) {
        this.scope       = scope;
        this.url         = data.url;
        this.interpolate = data.interpolate;
        this.title       = data.title;
    }

    return D3LineGraph;
}());

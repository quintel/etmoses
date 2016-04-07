/*globals Ajax*/

var D3LineGraph = (function () {
    'use strict';

    var svg,
        margin = { top: 20, right: 20, bottom: 30, left: 70 },
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

    function drawD3Graph(rawData) {
        var data = convertData(rawData),
            line = d3.svg.line()
                     .interpolate(this.interpolate)
                     .x(function (d) { return x(d.x); })
                     .y(function (d) { return y(d.y); });

        svg = d3.select(this.scope).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        x.domain(d3.extent(data, function (d) { return d.x; }));
        y.domain([0, d3.max(data, function (d) { return d.y; })]);

        svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

        svg.append("g")
            .attr("class", "y axis")
            .call(yAxis)
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(this.title);

        svg.append("path")
            .datum(data)
            .attr("class", "line")
            .attr("d", line);
    }

    D3LineGraph.prototype = {
        append: function () {
            Ajax.json(this.url, {}, drawD3Graph.bind(this));
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

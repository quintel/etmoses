/*globals LoadChartHelper,LoadChartsSettings,StrategyHelper*/

var D3LoadChart = (function () {
    'use strict';

    var xScale,  // Scales
        xScale2,
        yScale,
        yScale2,
        xAxis,   // Axis
        xAxis2,
        yAxis,
        yAxis2,
        context,
        svg,
        defs,
        previewLine,
        previewColorArea,
        issue,
        line,
        colorArea,
        legend,
        popOverEl,
        legendItem,
        brush,
        chartData,
        staticSettings,
        width,
        hoverLineGroup,
        hoverLine,

        currentWeek     = 0,
        margin          = { top: 20, right: 200, bottom: 70, left: 50 },
        height          = 500 - margin.top - margin.bottom,
        height2         = 50,
        msInWeek        = 6.048e+8,
        scaleCorrection = 1.05,
        chartLengths    = {
            long: 35040,
            short: 8760,
            annual: 365
        },
        customTimeFormat = d3.time.format.utc.multi([
            ["%H:%M", function (d) { return d.getUTCMinutes(); }],
            ["%H:%M", function (d) { return d.getUTCHours(); }],
            ["%b %d", function (d) { return d.getUTCDate() !== 1; }],
            ["%d %b", function (d) { return true; }]
        ]);


    function generateCapacity(capacity, data) {
        var extent = d3.extent(data[0].values, function (d) { return d.x; });

        return {
            key:      "Capacity",
            type:     "capacity",
            color:    LoadChartsSettings.capacity.color,
            area:     false,
            visible:  LoadChartsSettings.capacity.visible,
            values:   [
                { x: extent[0], y: capacity },
                { x: extent[1], y: capacity },
                { x: extent[0], y: capacity * -1 },
                { x: extent[1], y: capacity * -1 }
            ]
        };
    }

    function formatDateFromFrame(loads, frame) {
        var multiplier = -1,
            len        = loads.length,
            offset     = currentWeek === 0 ? 0 : (currentWeek - 1) * msInWeek;

        if (len === chartLengths.long || len === 673) {
            multiplier = 900000;
        } else if (len === chartLengths.short) {
            multiplier = 3600000;
        } else if (len === chartLengths.annual) {
            multiplier = 86400000;
        }

        return new Date((frame * multiplier) + offset);
    }

    function sampledData(loads) {
        var chunkSize, endAt, startAt, zeroWeek;

        if (currentWeek && currentWeek !== 0) {
            chunkSize = Math.floor(loads.length / 52);
            zeroWeek  = currentWeek - 1;
            startAt   = zeroWeek * chunkSize;
            endAt     = startAt + chunkSize;

            loads     = loads.slice(startAt, endAt);
        }

        return loads.map(function (y, x) {
            return { x: formatDateFromFrame(loads, x), y: y };
        });
    }

    function fetchLoad() {
        if (staticSettings.load) {
            return [staticSettings.load];
        } else if (StrategyHelper.anyStrategies()) {
            return [{ area: true,  type: 'load_strategies' },
                    { area: false, type: 'load' },
                    { area: true,  type: 'gas_strategies' },
                    { area: false, type: 'gas' }];
        } else {
            return [{ area: true, type: 'load' },
                    { area: true, type: 'gas' }];
        }
    }

    function transformData() {
        var settings, values,
            results = [],
            load    = fetchLoad(),
            data    = this.lastRequestedData;

        load.forEach(function (datum) {
            values   = data[datum.type];
            settings = LoadChartsSettings[datum.type || this.curveType || 'default'];

            if (values) {
                results.push({
                    key:     settings.name,
                    type:    datum.type,
                    values:  sampledData(values),
                    area:    datum.area,
                    color:   settings.color,
                    visible: settings.visible
                });
            }
        }.bind(this));

        if (data.capacity) {
            results.push(generateCapacity(data.capacity, results));
        }

        return results;
    }

    function drawPopOver(mousePosX, results) {
        var span, square, spanValue,
            keys = Object.keys(LoadChartsSettings);

        this.show();
        this.html('');
        this.css("left", mousePosX + "px");

        keys.shift();

        keys.forEach(function (chart) {
            if (results[chart]) {
                span   = $("<span>").addClass("wrap");
                square = $("<span>").addClass("square")
                                    .css("background-color", LoadChartsSettings[chart].color);
                spanValue = $("<span>").text(function () {
                    return Math.round(results[chart].y * 100) / 100;
                });

                span.append(square, spanValue);

                this.append(span);
            }
        }.bind(this));
    }

    function renderPartOfChart(value) {
        if (this.resolution === 'high' && value !== 0) {
            this.update();
        } else if (staticSettings.dateCallback) {
            this.resolution = 'high';
            staticSettings.dateCallback(value);
        } else if (value === 0) {
            this.resolution = 'low';
            window.currentTree.update();
        } else {
            this.resolution = 'high';
            window.currentTree.update();
        }
    }

    function renderWeek(scope) {
        var value = parseInt($(scope.target).val(), 10);

        currentWeek = value;

        scope.brush.clear();

        renderPartOfChart.call(this, value);
    }

    function all() {
        var chained = [];
        this.forEach(function (d) {
            if (d.visible) {
                chained = chained.concat(d.values);
            }
        });
        return chained;
    }

    function setYscaleDomain() {
        var extent = brush.extent(),
            ydomain = d3.extent(all.call(chartData), function (d) {
                if (brush.empty() || (extent[0] <= d.x && extent[1] >= d.x)) {
                    return d.y * scaleCorrection;
                }
            });

        if (ydomain[0] > 0) {
            ydomain[0] = 0;
        }

        if (ydomain[1] < 0) {
            ydomain[1] = 0;
        }

        yScale.domain(ydomain).nice();
    }

    function redrawPaths() {
        issue.select("path.line")
            .transition().duration(0)
            .attr("d", function (d) {
                return d.visible ? line(d.values) : null;
            });

        issue.select("path.line-bg")
            .transition().duration(0)
            .attr("d", function (d) {
                return d.visible && d.area ? colorArea(d.values) : null;
            });
    }

    //for brusher of the slider bar at the bottom
    function brushed() {
        xScale.domain(brush.empty() ? xScale2.domain() : brush.extent());

        svg.select(".x.axis")
              .transition().duration(0)
              .call(xAxis);

        setYscaleDomain();

        svg.select(".y.axis")
            .transition().duration(0)
            .call(yAxis);

        redrawPaths();
    }

    function roundDate(date) {
        var roundTo  = this.resolution === 'high' ? 15 : 60 * 24,
            rounding = 1000 * 60 * roundTo;

        return new Date(Math.floor(date.getTime() / rounding) * rounding);
    }

    function mousemove() {
        var mousePos   = d3.mouse(document.getElementById("mouse-tracker")),
            rawGraphX  = xScale.invert(mousePos[0]),
            graphX     = roundDate.call(this, rawGraphX),
            results    = {};

        chartData.forEach(function (d) {
            results[d.type] = d.values.find(function (val) {
                return typeof (val.x.getTime) === 'function'
                    && graphX.getTime() === val.x.getTime();
            });
        });

        drawPopOver.call(popOverEl, mousePos[0] + 60, results);

        d3.select("#hover-line")
            .attr("x1", mousePos[0])
            .attr("x2", mousePos[0])
            .style("opacity", 1);
    }

    function generateLine(x, y) {
        return d3.svg.line()
            .interpolate('step-after')
            .x(function (d) { return x(d.x); })
            .y(function (d) { return y(d.y); })
            .defined(function (d) { return d.x; });
    }

    function generateArea(x, y) {
        return d3.svg.area()
            .interpolate('step-after')
            .x(function (d) { return x(d.x); })
            .y0(function () { return y(0);   })
            .y1(function (d) { return y(d.y); });
    }

    function drawChartPart(klass, d3Line, d3Area) {
        var part = this.selectAll(klass).data(chartData),
            clip = klass.replace(/\./, '');

        part.enter().append("g")
            .attr("class", klass);

        part.append("path")
            .style("pointer-events", "none")
            .style("stroke", function (d) { return d.color; })
            .style("fill", "none")
            .attr("class", "line")
            .attr("clip-path", "url(#clip-" + clip + ")")
            .attr("id", function (d) {
                return "line-" + d.type;
            })
            .attr("d", function (d) {
                return d.visible ? d3Line(d.values) : null;
            });

        part.append("path")
            .style("pointer-events", "none")
            .style("fill", function (d) {
                return d.color;
            })
            .attr("clip-path", "url(#clip-" + clip + ")")
            .attr("opacity", 0.5)
            .attr("class", "line-bg")
            .attr("d", function (d) {
                return d.visible && d.area ? d3Area(d.values) : null;
            });

        part.exit().remove();

        return part;
    }

    D3LoadChart.prototype = {
        lastRequestedData: null,
        update: function (data) {
            this.lastRequestedData = data || this.lastRequestedData;

            chartData = transformData.call(this);

            xScale.domain(d3.extent(chartData[0].values, function (d) {
                return d.x;
            }));

            yScale.domain(d3.extent(all.call(chartData), function (d) {
                return d.y;
            }));

            xScale2.domain(xScale.domain());
            yScale2.domain(yScale.domain());

            context.select(".x-axis1").call(xAxis2);

            svg.selectAll("path").remove();

            //for slider part--------------------------------------------------

            var contextArea = d3.svg.area()
                .interpolate("step-after")
                .x(function (d) { return xScale2(d.x); })
                .y0(height2)
                .y1(0);

            context.append("path")
                .attr("class", "area")
                .attr("d", contextArea(chartData[0].values))
                .attr("fill", "#F1F1F2");

            //end slider part--------------------------------------------------
            drawChartPart.call(context, ".preview-issue", previewLine, previewColorArea);
            issue = drawChartPart.call(svg, ".issue", line, colorArea);

            context.append("g")
                .attr("class", "x brush")
                .call(brush)
                .selectAll("rect")
                .attr("height", height2)
                .attr("fill", "#060708");

            // Draw legend ----------------------------------------------------

            legend.selectAll(".legend-item").remove();
            legendItem = legend.selectAll(".legend-item").data(chartData);

            legendItem.enter().append("span")
                .attr("class", "legend-item")
                .on("click", function (d) {
                    d.visible = !d.visible;

                    LoadChartsSettings[d.type].visible = d.visible;

                    setYscaleDomain();

                    svg.select(".y.axis")
                        .transition()
                        .call(yAxis);

                    redrawPaths();

                    issue.select("rect")
                        .transition()
                        .attr("fill", function (d) {
                            return d.visible ? d.color : "#F1F1F2";
                        });
                })
                .on("mouseover", function (d) {
                    d3.select(this)
                        .select(".square")
                        .transition()
                        .style("background-color", function (d) {
                            return d.color;
                        });

                    d3.select("#line-" + d.type)
                        .transition()
                        .style("stroke-width", 2.5);
                })
                .on("mouseout", function (d) {
                    d3.select(this)
                        .select(".square")
                        .transition()
                        .style("background-color", function (d) {
                            return d.visible ? d.color : "#F1F1F2";
                        });

                    d3.select("#line-" + d.type)
                        .transition()
                        .style("stroke-width", 1.5);
                });

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

            brushed();
        },

        render: function (data) {
            var self = this;

            xScale  = d3.time.scale.utc().range([0, width]);
            xScale2 = d3.time.scale.utc().range([0, width]);
            yScale  = d3.scale.linear().range([height, 0]);
            yScale2 = d3.scale.linear().range([height2, 0]);

            xAxis   = d3.svg.axis().scale(xScale).orient("bottom")
                        .tickFormat(customTimeFormat)
                        .ticks(6);

            xAxis2  = d3.svg.axis().scale(xScale2).orient("bottom")
                        .tickFormat(customTimeFormat)
                        .ticks(6);

            yAxis   = d3.svg.axis().scale(yScale).orient("left");
            yAxis2  = d3.svg.axis().scale(yScale2).orient("left")

            brush   = d3.svg.brush()
                        .x(xScale2)
                        .on("brush", brushed);

            line             = generateLine(xScale, yScale);
            colorArea        = generateArea(xScale, yScale);
            previewLine      = generateLine(xScale2, yScale2);
            previewColorArea = generateArea(xScale2, yScale2);

            legend = d3.select(this.chartClass).append("div")
                .attr("class", "legend");

            svg = d3.select(this.chartClass).append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height)
                .append("g")
                .attr("transform", "translate(" + margin.left + ","
                                                + margin.top  + ")");

            // Create invisible rect for mouse tracking
            svg.append("rect")
                .attr("width", width)
                .attr("height", height)
                .attr("x", 0)
                .attr("y", 0)
                .attr("id", "mouse-tracker")
                .style("fill", "white");

            ////for slider part------------------------------------------------
            context = svg.append("g") // Brushing context box container
                .attr("transform", "translate(0, 440)")
                .attr("class", "context");

            context.append("g")
                .attr("class", "axis x-axis1")
                .attr("transform", "translate(0," + height2 + ")");

            defs = svg.append("defs")

            defs.append("clipPath")
                  .attr("id", "clip-issue")
                .append("rect")
                  .attr("width", width)
                  .attr("height", height);

            defs.append("clipPath")
                  .attr("id", "clip-preview-issue")
                .append("rect")
                  .attr("width", width)
                  .attr("height", height2);
            //end slider part--------------------------------------------------

            // draw line graph
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
                .attr("x", -10)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text(LoadChartsSettings[data.type || this.curveType].axisLabel);

            // Hover line
            hoverLineGroup = svg.append("g")
                  .attr("class", "hover-line");

            hoverLine = hoverLineGroup
                  .append("line")
                  .attr("id", "hover-line")
                  .attr("x1", 10).attr("x2", 10)
                  .attr("y1", 0).attr("y2", height + 10)
                  .style("pointer-events", "none")
                  .style("opacity", 1e-6);

            popOverEl = $("<div/>").addClass("pop-over-load-graph");

            $(this.chartClass).append(popOverEl);

            d3.select("#mouse-tracker")
                .on("mousemove", mousemove.bind(this))
                .on("mouseout", function () {
                    popOverEl.hide();

                    d3.select("#hover-line")
                        .style("opacity", 1e-6);
                });

            // Add mouseover events for hover line.
            $("select.load-date")
                .val('0')
                .off('change')
                .on('change', function (e) {
                    renderWeek.call(self, { target: e.target, brush: brush });
                });

            this.update(data);
        }
    };

    function D3LoadChart(chartClass, curveType, settings) {
        this.resolution = 'low';
        this.chartClass = chartClass;
        this.curveType  = curveType;
        staticSettings  = settings || {};
        width           = (staticSettings.width || 750 - margin.left - margin.right);
    }

    return D3LoadChart;
}());

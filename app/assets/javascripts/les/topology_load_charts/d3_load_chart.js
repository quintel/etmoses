/*globals LoadChartHelper,LoadChartsSettings,StrategyHelper,Transformator,
StackTransformator*/

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
        legend,
        popOverEl,
        legendItem,
        brush,
        chartData,
        staticSettings,
        width,
        hoverLineGroup,
        hoverLine,
        dateSelect,

        currentWeek     = 1,
        margin          = { top: 20, right: 0, bottom: 70, left: 75 },
        height          = 500 - margin.top - margin.bottom,
        height2         = 50,
        weeksInYear     = (365 / 7.0),

        // This is assuming every LES has a length of 35040. Shorter LES's will
        // break because of this line.
        //
        // TODO: Fix this static value so the 'resolution' of the LES is taken
        // into account.
        weekResolution   = 672,
        scaleCorrection  = 1.05,
        customTimeFormat = d3.time.format.utc.multi([
            ["%H:%M", function (d) { return d.getUTCMinutes(); }],
            ["%H:%M", function (d) { return d.getUTCHours(); }],
            ["%b %d", function (d) { return d.getUTCDate() !== 1; }],
            ["%d %b", function () { return true; }]
        ]),
        chartParts = {
            preview_issue: {
                line: undefined,
                colorArea: undefined,
                stackedArea: undefined
            },
            issue: {
                line: undefined,
                colorArea: undefined,
                stackedArea: undefined
            }
        },
        shown = {
            view_as: 'total',
            electricity: true,
            strategies: false
        };

    function drawPopOver(mousePosX, results) {
        var span, square, spanValue, color;

        this.show();
        this.html('');
        this.css("left", mousePosX + "px");

        for (var type in results) {
            if (results[type] && results[type].values && LoadChartsSettings[type].visible) {
                span   = $("<span>").addClass("wrap");
                square = $("<span>").addClass("square").css({
                    "background-color": results[type].color,
                    "opacity": 0.6
                });

                spanValue = $("<span>").text(function () {
                    return Math.round(results[type].values.y * 100) / 100;
                });

                span.append(square, spanValue);

                this.append(span);
            }
        }
    }

    function setLesOptions() {
        if (currentWeek !== 0) {
            this.lesOptions = {
                resolution:  'high',
                range_start: weekResolution * (currentWeek - 1),
                range_end:   weekResolution * currentWeek
            };
        } else {
            this.lesOptions = {
                resolution: 'low',
                range_start: 0,
                range_end:   weekResolution * weeksInYear
            };
        }
    }

    function renderWeek(scope) {
        var value = parseInt($(scope.target).val(), 10);

        currentWeek = value;

        scope.brush.clear();

        dateSelect.prop("disabled", true);

        if (staticSettings.dateCallback) {
            staticSettings.dateCallback(value);
        } else {
            setLesOptions.call(this);
            window.currentTree.update();
        }
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
                    if (shown.view_as === 'stacked') {
                        return (d.y + d.offset) * scaleCorrection;
                    } else {
                        return d.y * scaleCorrection;
                    }
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

    function setLine(d, scope) {
        if (d.visible && !(shown.view_as === 'stacked')) {
            return chartParts[scope].line(d.values);
        } else {
            return null;
        }
    }

    function setArea(d, scope) {
        if (d.visible && d.area) {
            if (!(shown.view_as === 'stacked')) {
                return chartParts[scope].colorArea(d.values);
            } else {
                return chartParts[scope].stackedArea(d.values);
            }
        } else {
            return null;
        }
    }

    function redrawPaths() {
        issue.select("path.line")
            .transition().duration(0)
            .attr("d", function (d) {
                return setLine(d, 'issue');
            });

        issue.select("path.line-bg")
            .transition().duration(0)
            .attr("d", function (d) {
                return setArea(d, 'issue');
            });

        svg.select("line.zero-line")
            .attr("y1", yScale(0))
            .attr("y2", yScale(0))
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
        var roundTo  = this.lesOptions.resolution === 'high' ? 15 : 60 * 24,
            rounding = 1000 * 60 * roundTo;

        return new Date(Math.floor(date.getTime() / rounding) * rounding);
    }

    function mousemove() {
        var mousePos   = d3.mouse(document.getElementById("mouse-tracker")),
            rawGraphX  = xScale.invert(mousePos[0]),
            graphX     = roundDate.call(this, rawGraphX),
            results    = {};

        chartData.forEach(function (d) {
            results[d.type] = {
                color:  d.color,
                values: d.values.find(function (val) {
                    return typeof (val.x.getTime) === 'function'
                        && graphX.getTime() === val.x.getTime();
                })
            };
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

    function generateColorArea(x, y) {
        return d3.svg.area()
            .interpolate('step-after')
            .x(function (d) { return x(d.x); })
            .y0(function () { return y(0);   })
            .y1(function (d) { return y(d.y); });
    }

    function generateStackedArea(x, y) {
        return d3.svg.area()
            .interpolate('step-after')
            .x(function (d) {  return x(d.x); })
            .y0(function (d) { return y(d.offset); })
            .y1(function (d) { return y(d.offset + d.y); });
    }

    function setShapes(scope, x, y) {
        chartParts[scope].line = generateLine(x, y);
        chartParts[scope].colorArea = generateColorArea(x, y);
        chartParts[scope].stackedArea = generateStackedArea(x, y);
    }

    function drawChartPart(klass) {
        var part = this.selectAll(klass).data(chartData),
            scope = klass.replace(/\./, '');

        part.enter().append("g")
            .attr("class", klass);

        part.append("path")
            .style("pointer-events", "none")
            .style("stroke", function (d) { return d.color; })
            .style("fill", "none")
            .attr("class", "line")
            .attr("clip-path", "url(#clip-" + scope + ")")
            .attr("id", function (d) {
                return "line-" + d.type;
            })
            .attr("d", function (d) {
                return setLine(d, scope);
            });

        part.append("path")
            .style("pointer-events", "none")
            .style("fill", function (d) {
                return d.color;
            })
            .attr("clip-path", "url(#clip-" + scope + ")")
            .attr("opacity", 0.5)
            .attr("class", "line-bg")
            .attr("d", function (d) {
                return setArea(d, scope);
            });

        part.exit().remove();

        return part;
    }

    function transformData() {
        var data = new Transformator(this, staticSettings.load, currentWeek)
            .transform(shown);

        if (shown.view_as === 'stacked') {
            data = new StackTransformator(data).transform();
        }

        return data;
    }

    D3LoadChart.prototype = {
        lastRequestedData: null,
        lesOptions: {
            resolution:  'high',
            range_start: 0,
            range_end:   weekResolution
        },
        view: function (attr, newAttr) {
            shown[attr] = newAttr;

            return this;
        },
        update: function (data) {
            var contextArea, legendItemClass;

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
            svg.selectAll("line.zero-line").remove();

            // Zero line ------------------------------------------------------

            svg.append("line")
                .attr("class", "zero-line")
                .attr("x1", 0)
                .attr("x2", width)
                .attr("y1", yScale(0))
                .attr("y2", yScale(0))

            //for slider part--------------------------------------------------

            contextArea = d3.svg.area()
                .interpolate("step-after")
                .x(function (d) { return xScale2(d.x); })
                .y0(height2)
                .y1(0);

            context.append("path")
                .attr("class", "area")
                .attr("d", contextArea(chartData[0].values))
                .attr("fill", "#F1F1F2");

            //end slider part--------------------------------------------------
            drawChartPart.call(context, ".preview_issue");
            issue = drawChartPart.call(svg, ".issue");

            context.append("g")
                .attr("class", "x brush")
                .call(brush)
                .selectAll("rect")
                .attr("height", height2)
                .attr("fill", "#060708");

            // Draw legend ----------------------------------------------------

            legend.selectAll(".legend-item").remove();
            legendItem = legend.selectAll(".legend-item").data(chartData);

            legendItemClass = "legend-item";
            legendItemClass += (chartData.length > 3) ? " side" : "";

            legendItem.enter().append("span")
                .attr("class", legendItemClass)
                .on("click", function (d) {
                    if (shown.view_as === 'stacked') {
                        return false;
                    }

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

                    d3.select(".line." + d.type)
                        .transition()
                        .style("stroke-width", 1.5);
                })
                .on("mouseout", function (d) {
                    d3.select(this)
                        .select(".square")
                        .transition()
                        .style("background-color", function (d) {
                            return d.visible ? d.color : "#F1F1F2";
                        });

                    d3.select(".line." + d.type)
                        .transition()
                        .style("stroke-width", 1.0);
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

            dateSelect.prop("disabled", false);

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
            yAxis2  = d3.svg.axis().scale(yScale2).orient("left");

            brush   = d3.svg.brush()
                        .x(xScale2)
                        .on("brush", brushed);

            setShapes('issue', xScale, yScale);
            setShapes('preview_issue', xScale2, yScale2);

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

            defs = svg.append("defs");

            defs.append("clipPath")
                  .attr("id", "clip-issue")
                .append("rect")
                  .attr("width", width)
                  .attr("height", height);

            defs.append("clipPath")
                  .attr("id", "clip-preview_issue")
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
            dateSelect = $("select.load-date");
            dateSelect.removeClass("hidden")
                .val(currentWeek.toString())
                .off('change')
                .on('change', function (e) {
                    renderWeek.call(self, { target: e.target, brush: brush });
                });

            this.update(data);
        }
    };

    function D3LoadChart(chartClass, curveType, settings) {
        this.chartClass = chartClass;
        this.curveType  = curveType || 'default';
        staticSettings  = settings || {};
        width           = (staticSettings.width || 500);
    }

    return D3LoadChart;
}());

/*globals Legend,LoadChartHelper,LoadChartsSettings,PopOver,
StackTransformer,StrategyHelper,Transformer*/

var D3LoadChart = (function () {
    'use strict';

    var xScale,  // Scales
        xScale2,
        yScale,
        yScale2,
        xAxis,   // Axis
        xAxis2,
        yAxis,
        context,
        svg,
        defs,
        legend,
        legendObj,
        popOverEl,
        popOver,
        brush,
        chartData,
        hoverLineGroup,

        currentWeek     = 1,
        margin          = { top: 20, right: 0, bottom: 70, left: 75 },
        height2         = 50,
        brushMargin     = 40,
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
        };

    function setLesOptions() {
        var lesOptions;

        if (currentWeek !== 0) {
            lesOptions = {
                resolution:  'high',
                range_start: weekResolution * (currentWeek - 1),
                range_end:   weekResolution * currentWeek
            };
        } else {
            lesOptions = {
                resolution: 'low',
                range_start: 0,
                range_end:   weekResolution * weeksInYear
            };
        }

        $.extend(this.settings, lesOptions);
    }

    function renderWeek(scope) {
        var value = parseInt($(scope.target).val(), 10);

        currentWeek = value;

        scope.brush.clear();

        this.dateSelect.prop("disabled", true);

        if (this.settings.dateCallback) {
            this.settings.dateCallback(value);
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

    function setExtent(d) {
        var extent = brush.extent();

        if (brush.empty() || (extent[0] <= d.x && extent[1] >= d.x)) {
            if (this.settings.view_as === 'stacked') {
                return (d.y + d.offset) * scaleCorrection;
            } else {
                return d.y * scaleCorrection;
            }
        }
    }

    function setLine(d, scope) {
        if (d.visible && !(this.settings.view_as === 'stacked')) {
            return chartParts[scope].line(d.values);
        } else {
            return null;
        }
    }

    function setArea(d, scope) {
        if (d.visible && d.area) {
            if (!(this.settings.view_as === 'stacked')) {
                return chartParts[scope].colorArea(d.values);
            } else {
                return chartParts[scope].stackedArea(d.values);
            }
        } else {
            return null;
        }
    }

    //for brusher of the slider bar at the bottom
    function brushed() {
        xScale.domain(brush.empty() ? xScale2.domain() : brush.extent());

        svg.select(".x.axis")
              .transition().duration(0)
              .call(xAxis);

        this.setYscaleDomain(true);
    }

    function roundDate(date) {
        var roundTo  = this.settings.resolution === 'high' ? 15 : 60 * 24,
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

        popOver.show(mousePos[0] + 60, results);

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

    function drawChartPart(scope, klass) {
        var part     = scope.selectAll(klass).data(chartData),
            clipName = klass.replace(/\./, '');

        part.enter().append("g")
            .attr("class", klass);

        part.append("path")
            .style("pointer-events", "none")
            .style("stroke", function (d) { return d.color; })
            .style("fill", "none")
            .attr("class", "line")
            .attr("clip-path", "url(#clip-" + clipName + ")")
            .attr("id", function (d) {
                return "line-" + d.type;
            })
            .attr("d", function (d) {
                return setLine.call(this, d, clipName);
            }.bind(this));

        part.append("path")
            .style("pointer-events", "none")
            .style("fill", function (d) {
                return d.color;
            })
            .attr("clip-path", "url(#clip-" + clipName + ")")
            .attr("opacity", this.seriesOpacity || 0.5)
            .attr("class", "line-bg")
            .attr("d", function (d) {
                return setArea.call(this, d, clipName);
            }.bind(this));

        part.exit().remove();

        return part;
    }

    function transformData() {
        var data = Transformer.transform(this, currentWeek);

        if (this.settings.view_as === 'stacked') {
            data = StackTransformer.transform(data);
        }

        return data;
    }

    function redrawPath(key) {
        var issue = this[key.camelize()];

        issue.select("path.line")
            .transition().duration(0)
            .attr("d", function (d) {
                return setLine.call(this, d, key);
            }.bind(this));

        issue.select("path.line-bg")
            .transition().duration(0)
            .attr("d", function (d) {
                return setArea.call(this, d, key);
            }.bind(this));
    }

    D3LoadChart.prototype = $.extend({}, D3BaseChart.prototype, {
        lastRequestedData: null,
        view: function (attr, newAttr) {
            this.settings[attr] = newAttr;

            return this;
        },
        axisLabel: function (data) {
            if (this.scaling) {
                return this.scaling.unit.name
            } else {
                return LoadChartsSettings[data.type || this.curveType].axisLabel;
            }
        },
        setYscaleDomain: function (mainOnly) {
            var ydomain = d3.extent(all.call(chartData), setExtent.bind(this));

            if (ydomain[0] > 0) { ydomain[0] = 0; }
            if (ydomain[1] < 0) { ydomain[1] = 0; }

            yScale.domain(ydomain).nice();

            if (! mainOnly) {
                yScale2.domain(ydomain).nice();
            }

            svg.select(".y.axis").transition().call(yAxis);

            this.redrawPaths();
        },
        redrawPaths: function () {
            Object.keys(chartParts).forEach(redrawPath.bind(this));

            svg.select("line.zero-line")
                .attr("y1", yScale(0))
                .attr("y2", yScale(0));
        },
        update: function (data) {
            var contextArea;

            this.lastRequestedData = data || this.lastRequestedData;

            chartData = transformData.call(this);

            if (chartData.length < 1) {
                throw "Charts are empty";
            }

            xScale.domain(d3.extent(chartData[0].values, function (d) {
                return d.x;
            }));

            yScale.domain(d3.extent(all.call(chartData), function (d) {
                return d.y + (d.offset || 0);
            }));

            xScale2.domain(xScale.domain());
            yScale2.domain(yScale.domain());

            context.select(".x-axis1").call(xAxis2);

            svg.selectAll("path").remove();

            // Zero line ------------------------------------------------------
            svg.select("line.zero-line")
                .attr("x1", 0)
                .attr("x2", this.width)
                .attr("y1", yScale(0))
                .attr("y2", yScale(0));

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
            this.previewIssue = drawChartPart.call(this, context, ".preview_issue");
            this.issue        = drawChartPart.call(this, svg, ".issue");

            context.append("g")
                .attr("class", "x brush")
                .call(brush)
                .selectAll("rect")
                .attr("height", height2)
                .attr("fill", "#060708");

            this.dateSelect.prop("disabled", false);

            legendObj.draw(chartData);

            brushed.call(this);
        },

        maxYvalue: function (data) {
            return d3.max(data.load.total);
        },

        getScaling: function (data) {
            var scaling,
                maxYvalue,
                axisLabel = this.axisLabel(data);

            if (/^[a-zA-Z]W$/.test(axisLabel)) {
                scaling = new Quantity(this.maxYvalue(data), axisLabel).smartScale();
            }

            return scaling;
        },

        render: function (data) {
            var self = this;

            this.scaling = this.getScaling(data);

            d3.select(this.chartClass).html('');

            xScale  = d3.time.scale.utc().range([0, this.width]);
            xScale2 = d3.time.scale.utc().range([0, this.width]);
            yScale  = d3.scale.linear().range([this.height, 0]);
            yScale2 = d3.scale.linear().range([height2, 0]);

            xAxis   = d3.svg.axis().scale(xScale).orient("bottom")
                        .tickFormat(customTimeFormat)
                        .ticks(6);

            xAxis2  = d3.svg.axis().scale(xScale2).orient("bottom")
                        .tickFormat(customTimeFormat)
                        .ticks(6);

            yAxis   = d3.svg.axis().scale(yScale).orient("left");

            brush   = d3.svg.brush()
                        .x(xScale2)
                        .on("brush", brushed.bind(this));

            setShapes('issue', xScale, yScale);
            setShapes('preview_issue', xScale2, yScale2);

            legend = d3.select(this.chartClass).append("div")
                .attr("class", "legend");

            svg = d3.select(this.chartClass).append("svg")
                .attr("width", this.width + margin.left + margin.right)
                .attr("height", this.height + margin.top + margin.bottom + height2)
                .append("g")
                .attr("transform", "translate(" + margin.left + ","
                                                + margin.top  + ")");

            // Create invisible rect for mouse tracking
            svg.append("rect")
                .attr("width", this.width)
                .attr("height", this.height)
                .attr("x", 0)
                .attr("y", 0)
                .attr("id", "mouse-tracker")
                .style("fill", "white");

            svg.append("line")
                .attr("class", "zero-line");

            ////for slider part------------------------------------------------
            context = svg.append("g") // Brushing context box container
                .attr("transform", "translate(0, " + (this.height + brushMargin) + ")")
                .attr("class", "context");

            context.append("g")
                .attr("class", "axis x-axis1")
                .attr("transform", "translate(0," + height2 + ")");

            defs = svg.append("defs");

            defs.append("clipPath")
                  .attr("id", "clip-issue")
                .append("rect")
                  .attr("width", this.width)
                  .attr("height", this.height);

            defs.append("clipPath")
                  .attr("id", "clip-preview_issue")
                .append("rect")
                  .attr("width", this.width)
                  .attr("height", height2);
            //end slider part--------------------------------------------------

            // draw line graph
            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + this.height + ")")
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
                .text(this.axisLabel(data));

            // Hover line
            hoverLineGroup = svg.append("g")
                  .attr("class", "hover-line");

            hoverLineGroup
                  .append("line")
                  .attr("id", "hover-line")
                  .attr("x1", 10).attr("x2", 10)
                  .attr("y1", 0).attr("y2", this.height + 10)
                  .style("pointer-events", "none")
                  .style("opacity", 1e-6);

            popOverEl = $("<div/>").addClass("pop-over-load-graph");

            $(this.chartClass).append(popOverEl);

            popOver   = new PopOver(popOverEl, this.seriesOpacity);
            legendObj = new Legend(this, legend);

            // Add mouseover events for hover line.
            d3.select("#mouse-tracker")
                .on("mousemove", mousemove.bind(this))
                .on("mouseout", function () {
                    popOverEl.hide();

                    d3.select("#hover-line")
                        .style("opacity", 1e-6);
                });

            this.dateSelect = $("select.load-date");
            this.dateSelect.removeClass("hidden")
                .val(currentWeek.toString())
                .off('change')
                .on('change', function (e) {
                    renderWeek.call(self, { target: e.target, brush: brush });
                });

            this.update(data);
        }
    });

    function D3LoadChart(chartClass, curveType, settings) {
        D3BaseChart.call(this, chartClass);

        this.curveType  = curveType || 'default';
        this.settings   = $.extend(DefaultSettings, settings);
        this.width      = 500;
        this.height     = 410;
    }

    return D3LoadChart;
}());

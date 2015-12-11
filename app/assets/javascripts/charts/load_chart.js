/*globals LoadChartHelper,nv,localSettings*/
var LoadChart = (function () {
    'use strict';

    var chartLengths = {
        long: 35040,
        short: 8760
    };

    function formatDateFromFrame(frame) {
        var multiplier = -1,
            len = this.data[0].values.length;

        if (len === chartLengths.long) {
            multiplier = 900000;
        } else if (len === chartLengths.short) {
            multiplier = 3600000;
        }

        if (multiplier === -1) {
            return frame;
        } else {
            return LoadChartHelper.formatDate(new Date(frame * multiplier));
        }
    }

    function loadChartLocation() {
        return parseInt(this.intoSelector.replace(/\D/g, ''), 10);
    }

    function createChart() {
        var chart = nv.models.lineWithFocusChart();
        chart.options({
            duration: 0,
            transitionDuration: 0,
            interpolate: 'linear',
            forceY: [0.0]
        });
        chart.useVoronoi(false);
        chart.lines.duration(0);
        chart.lines2.duration(0);
        chart.lines2.forceY([0.0]);
        chart.lines.interpolate('step-after');
        chart.lines2.interpolate('step-after');
        chart.xAxis.tickFormat(formatDateFromFrame.bind(this));
        chart.x2Axis.axisLabel("Time").tickFormat(formatDateFromFrame.bind(this));

        chart.yAxis.axisLabel(this.axisLabels[this.curve_type])
            .axisLabelDistance(0).tickFormat(d3.format(',.3r'));

        chart.y2Axis.axisLabel(this.axisLabels[this.curve_type])
            .axisLabelDistance(0).tickFormat(d3.format(',.3r'));

        chart.brush.on('brushend', this.setGlobalBrushFocus);

        LoadChartHelper.charts[loadChartLocation.call(this) - 1] = chart;
        LoadChartHelper.updateBrush(loadChartLocation.call(this));

        $("g.tick.zero text").text("0.00");

        return chart;
    }

    function addGraph(data) {
        var chart = createChart.call(this);
        d3.select(this.intoSelector).datum(data).call(chart);
        chart.update();
        LoadChartHelper.toggleCapacity(loadChartLocation.call(this));
    }

    function generateCapacity(data) {
        var total,
            top_line = data[0].values.map(function (sample) {
                return { x: sample.x, y: this.capacity };
            }.bind(this)),
            bottom_line = data[0].values.map(function (sample) {
                return { x: sample.x, y: this.capacity * -1 };
            }.bind(this));

        bottom_line.reverse().unshift({
            x: bottom_line[0].x + 1,
            y: bottom_line[0].y
        });

        total = bottom_line.concat(top_line);

        return {
            key: "Capacity",
            type: "capacity",
            color: LoadChartsSettings['capacity'].color,
            values: total,
            disabled: !LoadChartsSettings['capacity'].enabled
        };
    }

    function sampledData(loads) {
        var chunkSize, endAt, startAt, zeroWeek;

        if (LoadChartHelper.currentWeek && LoadChartHelper.currentWeek !== 0) {
            chunkSize = Math.floor(loads.length / 52);
            zeroWeek  = LoadChartHelper.currentWeek - 1;
            startAt   = zeroWeek * chunkSize;
            endAt     = startAt + chunkSize;

            return window.downsampleCurve(loads.slice(startAt, endAt), chunkSize, startAt);
        } else {
            return window.downsampleCurve(loads, 365);
        }
    }

    function renderChart() {
        $(this.intoSelector).empty();

        var results = [];

        this.data.forEach(function (datum) {
            if (datum.values) {
                results.push({
                    key:    datum.name,
                    type:   datum.type,
                    values: sampledData.call(this, datum.values),
                    area:   datum.area,
                    color:  LoadChartsSettings[datum.type].color
                });
            }
        }.bind(this));

        if (this.capacity) {
            results.push(generateCapacity.call(this, results));
        }

        // Add an extra data point to make the "step-after" smoothing fit better
        // (otherwise it appears that the last frame is not present).
        results.forEach(function (datum) {
            var last = datum.values[datum.values.length - 1];
            if (last) {
                datum.values.push({ x: last.x + 1, y: last.y });
            }
        });

        nv.addGraph(addGraph.bind(this, results));
    }

    function selectDatePortion(dateEl) {
        var value = parseInt(dateEl.val(), 10);
        LoadChartHelper.currentWeek = value;
        LoadChartHelper.forceReload = true;
        LoadChartHelper.clearBrush();
        $("select[name=date-select]").val(value);
        renderChart.call(this, value);
    }

    function drawDateSelect() {
        var endWeek, optionEl, startWeek, week, i,
            epoch = new Date(0),
            msInWeek = 604800000,
            dateEl = $('<select name="date-select" class="form-control" style="max-width: 300px"></select>');

        dateEl.append($('<option value="0">Whole year</option>'));

        for (week = i = 0; i < 52; week = ++i) {
            startWeek = new Date(epoch.getDate() + (msInWeek * week));
            endWeek = new Date(startWeek.getDate() + (msInWeek * week) + msInWeek - (msInWeek / 7));
            if (week === 51) {
                endWeek = new Date(endWeek.getDate() - 1000);
            }
            optionEl = $("<option value='" + (week + 1) + "'></option>");
            optionEl.text((LoadChartHelper.formatDate(startWeek)) + " - " + (LoadChartHelper.formatDate(endWeek)));
            dateEl.append(optionEl);
        }

        dateEl.change(selectDatePortion.bind(this, dateEl));

        $(this.intoSelector).after(dateEl);

        if (LoadChartHelper.currentWeek) {
            return $("select[name=date-select]").val(LoadChartHelper.currentWeek);
        }
    }

    LoadChart.prototype = {
        intoSelector: null,
        axisLabels: {
            "default": 'kW',
            flex: 'kW',
            inflex: 'kW',
            use: '',
            availability: '',
            price: '€'
        },

        render: function (intoSelector, week) {
            if (week === null) {
                week = 0;
            }

            this.intoSelector = intoSelector;
            renderChart.call(this, week);
            drawDateSelect.call(this);
        },

        setGlobalBrushFocus: function () {
            LoadChartHelper.globalBrushExtent = d3.event.target.extent();
            localSettings.set('global_brush_extent', d3.event.target.extent());
        }
    };

    function LoadChart(data, capacity, curve_type) {
        this.data = data;
        this.capacity = capacity;
        this.curve_type = curve_type;
    }

    return LoadChart;

}());

window.LoadChart = LoadChart;

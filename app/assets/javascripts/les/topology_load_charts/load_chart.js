/*globals LoadChartHelper,LoadChartsSettings,nv,localSettings*/
var LoadChart = (function () {
    'use strict';

    var chartLengths = {
        long: 35040,
        short: 8760,
        annual: 365
    };

    function formatDateFromFrame(frame) {
        var multiplier = -1,
            len        = this.data[0].values.length,
            offset     = $("select[name=date-select]")
                            .selectedOption(LoadChartHelper.currentWeek)
                            .data('startWeek') || 0;

        if (len === chartLengths.long) {
            multiplier = 900000;
        } else if (len === chartLengths.short) {
            multiplier = 3600000;
        } else if (len === chartLengths.annual) {
            multiplier = 86400000;
        }

        if (multiplier === -1) {
            return frame;
        } else {
            return LoadChartHelper.formatDate(new Date((frame * multiplier) + offset));
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
            color: LoadChartsSettings.capacity.color,
            values: total,
            disabled: !LoadChartsSettings.capacity.enabled
        };
    }

    function sampledData(loads) {
        var chunkSize, endAt, startAt, zeroWeek;

        if (LoadChartHelper.currentWeek && LoadChartHelper.currentWeek !== 0) {
            chunkSize = Math.floor(loads.length / 52);
            zeroWeek  = LoadChartHelper.currentWeek - 1;
            startAt   = zeroWeek * chunkSize;
            endAt     = startAt + chunkSize;

            loads     = loads.slice(startAt, endAt);
        }

        return loads.map(function (y, x) {
            return { x: x, y: y };
        });
    }

    function renderChart() {
        $(this.intoSelector).empty();

        nv.addGraph(this.updateGraph.bind(this));
    }

    function renderPartOfChart(value) {
        // Load large chart
        if (window.currentTree.resolution === 'high' && value !== 0) {
            renderChart.call(this);
        } else if (value === 0) {
            window.currentTree.lesses[1].strategies.toggleLoading();
            window.currentTree.set('low').update();
        } else {
            window.currentTree.lesses[1].strategies.toggleLoading();
            window.currentTree.set('high').update();
        }
    }

    function selectDatePortion(dateEl) {
        var value = parseInt(dateEl.val(), 10);

        LoadChartHelper.currentWeek = value;
        LoadChartHelper.forceReload = true;
        LoadChartHelper.clearBrush();

        if (this.dateSelectCallback) {
            this.dateSelectCallback(value);
        } else {
            $("select[name=date-select]").val(value);

            renderPartOfChart.call(this, value);
        }
    }

    function generateWeeks() {
        var startWeek, endWeek, optionEl, week,
            epoch    = new Date(0),
            msInWeek = 604800000;

        $(this).append($('<option value="0">Whole year</option>'));

        for (week = 0; week < 52; week++) {
            startWeek = new Date(epoch.getDate() + (msInWeek * week));
            endWeek   = new Date(startWeek.getDate() + (msInWeek * week)
                                 + msInWeek - (msInWeek / 7));

            if (week === 51) {
                endWeek = new Date(endWeek.getDate() - 1000);
            }

            optionEl = $("<option value='" + (week + 1) + "'></option>");
            optionEl.set('startWeek', startWeek.getTime());
            optionEl.text((LoadChartHelper.formatDate(startWeek)) + " - " +
                          (LoadChartHelper.formatDate(endWeek)));

            $(this).append(optionEl);
        }
    }

    function drawDateSelect() {
        var dateEl = $('<select name="date-select" class="form-control"></select>');

        generateWeeks.call(dateEl);
        dateEl.change(selectDatePortion.bind(this, dateEl));

        $(this.intoSelector).after(dateEl);

        if (LoadChartHelper.currentWeek) {
            return $("select[name=date-select]").val(LoadChartHelper.currentWeek);
        }
    }

    function mapData(rawData) {
        var results = [];

        rawData.forEach(function (datum) {
            var color = (
                LoadChartsSettings[datum.type || this.curve_type] ||
                LoadChartsSettings['default']
            ).color;

            if (datum.values) {
                results.push({
                    key:    datum.name,
                    type:   datum.type,
                    values: sampledData.call(this, datum.values),
                    area:   datum.area,
                    color:  color
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

        return results;
    }

    LoadChart.prototype = {
        intoSelector: null,
        chart: null,
        axisLabels: {
            "default": 'kW',
            flex: 'kW',
            inflex: 'kW',
            use: '',
            availability: '',
            price_curve: '€',
            behavior_profile: 'On/Off'
        },

        updateGraph: function() {
            if (!this.chart) {
                this.chart = createChart.call(this);
            }

            d3.select(this.intoSelector)
                .datum(mapData.call(this, this.data))
                .call(this.chart);

            this.chart.update();
            LoadChartHelper.toggleCapacity(loadChartLocation.call(this));
        },

        setGlobalBrushFocus: function () {
            LoadChartHelper.globalBrushExtent = d3.event.target.extent();

            if (window.localSettings) {
                localSettings.set('global_brush_extent', d3.event.target.extent());
            }
        },

        render: function (intoSelector, dateSelectCallback) {
            this.intoSelector = intoSelector;
            this.dateSelectCallback = dateSelectCallback || false;

            renderChart.call(this);
            drawDateSelect.call(this);
        }
    };

    function LoadChart(data, capacity, curve_type) {
        this.data       = data;
        this.capacity   = capacity;
        this.curve_type = curve_type;
    }

    return LoadChart;
}());

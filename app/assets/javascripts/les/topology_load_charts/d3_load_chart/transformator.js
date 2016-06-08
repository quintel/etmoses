var Transformator = (function () {
    'use strict';

    var currentWeek,
        msInWeek     = 6.048e+8,
        chartLengths = {
            long: 35040,
            short: 8760,
            annual: 365
        };

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

    function fetchLoad() {
        if (this.load) {
            return this.load;
        } else if (StrategyHelper.anyStrategies()) {
            return [{ area: true,  type: 'load_strategies' },
                    { area: false, type: 'load' },
                    { area: true,  type: 'gas_strategies' },
                    { area: false, type: 'gas' },
                    { area: true,  type: 'heat_strategies' },
                    { area: false, type: 'heat' }];
        } else {
            return [{ area: true, type: 'load' },
                    { area: true, type: 'gas' },
                    { area: true, type: 'heat' }];
        }
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

    function setCoords(loads) {
        return loads.map(function (y, x) {
            return { x: formatDateFromFrame(loads, x), y: y };
        });
    }

    function isShown(chartType) {
        var type = this.view_carrier;

        if (this.strategies && StrategyHelper.anyStrategies()) {
            type += "_strategies";
        }

        return this.view_as === 'total' || chartType === type;
    }

    function setTotalLoad(datum, values) {
        var settings = LoadChartsSettings[datum.type || this.d3Chart.curveType];

        return {
            key:     settings.name,
            type:    datum.type,
            values:  setCoords(values),
            area:    datum.area,
            color:   settings.color,
            visible: settings.visible
        };
    }

    function setLoadsPerTech(values) {
        for (var tech in values.tech_loads) {
            if (!LoadChartsSettings[tech]) {
                LoadChartsSettings[tech] = { visible: true };
            }

            this.results.push({
                key:     I18n.translations.en.inputs[tech],
                type:    tech,
                values:  setCoords(values.tech_loads[tech]),
                area:    (this.shown.view_as === 'stacked'),
                color:   ChartColors[tech],
                visible: LoadChartsSettings[tech].visible
            });
        }
    }

    function setLoad(datum) {
        var values = this.data[datum.type] || datum.values;

        if (isShown.call(this.shown, datum.type) && values.total) {
            if (this.shown.view_as === 'total') {
                this.results.push(setTotalLoad.call(this, datum, values.total));
            } else {
                setLoadsPerTech.call(this, values);
            }
        }
    }

    Transformator.prototype = {
        transform: function () {
            this.results = [];
            this.shown   = this.d3Chart.shown;

            fetchLoad.call(this).forEach(setLoad.bind(this));

            if (this.data.capacity && this.shown.view_as === 'total') {
                this.results.push(
                    generateCapacity(this.data.capacity, this.results));
            }

            return this.results;
        }
    };

    function Transformator(d3Chart, thisCurrentWeek) {
        this.d3Chart = d3Chart;
        this.load    = this.d3Chart.staticSettings.load;
        this.data    = this.d3Chart.lastRequestedData;

        currentWeek  = thisCurrentWeek;
    }

    return Transformator;
}());

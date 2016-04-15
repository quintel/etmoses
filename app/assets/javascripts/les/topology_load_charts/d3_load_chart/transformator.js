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
            return [this.load];
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
        var type = (this.electricity ? 'load' : 'gas');

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
            values:  setCoords(values.total),
            area:    datum.area,
            color:   settings.color,
            visible: settings.visible
        };
    }

    function setLoadsPerTech(values) {
        for (var tech in values.tech_loads) {
            LoadChartsSettings[tech] = { visible: true };

            this.results.push({
                key:     I18n.translations.en.inputs[tech],
                type:    tech,
                values:  setCoords(values.tech_loads[tech]),
                area:    (this.shown.view_as === 'stacked'),
                color:   ChartColors[tech],
                visible: true
            });
        }
    }

    function setLoad(datum) {
        var settings,
            values = this.data[datum.type];

        if (values.total && isShown.call(this.shown, datum.type)) {
            if (this.shown.view_as === 'total') {
                this.results.push(setTotalLoad.call(this, datum, values));
            } else {
                setLoadsPerTech.call(this, values);
            }
        }
    }

    Transformator.prototype = {
        transform: function (shown) {
            this.results = [];
            this.shown   = shown;

            fetchLoad.call(this).forEach(setLoad.bind(this));

            if (this.data.capacity && this.shown.view_as === 'total') {
                this.results.push(
                    generateCapacity(this.data.capacity, this.results));
            }

            return this.results;
        }
    };

    function Transformator(d3Chart, load, thisCurrentWeek) {
        this.d3Chart = d3Chart;
        this.load    = load;
        this.data    = this.d3Chart.lastRequestedData;

        currentWeek  = thisCurrentWeek;
    }

    return Transformator;
}());

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
        if (this.settings.load) {
            return this.settings.load;
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
        var type = this.settings.view_carrier;

        if (this.strategies && StrategyHelper.anyStrategies()) {
            type += "_strategies";
        }

        return isStaticLoadOrTotal.call(this) || chartType === type;
    }

    function setTotalLoad(datum, values) {
        var type     = (datum.type || this.d3Chart.curveType),
            settings = LoadChartsSettings[type];

        if (!settings) {
            throw "No settings available for '" + type + "'";
        }

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
                area:    (this.settings.view_as === 'stacked'),
                color:   $(".technologies.hidden span." + tech).data('color'),
                visible: LoadChartsSettings[tech].visible
            });
        }
    }

    function isStaticLoadOrTotal() {
        return (this.settings.load || this.settings.view_as === 'total');
    }

    function setLoad(datum) {
        var values = datum.values || this.data[datum.type];

        if (isShown.call(this, datum.type) && values.total) {
            if (isStaticLoadOrTotal.call(this)) {
                this.results.push(setTotalLoad.call(this, datum, values.total));
            } else {
                setLoadsPerTech.call(this, values);
            }
        }
    }

    return {
        transform: function (d3Chart, thisCurrentWeek) {
            this.results  = [];
            this.data     = d3Chart.lastRequestedData;
            this.settings = d3Chart.settings;

            currentWeek   = thisCurrentWeek;

            fetchLoad.call(this).forEach(setLoad.bind(this));

            if (this.data.capacity && this.settings.view_as === 'total') {
                this.results.push(
                    generateCapacity(this.data.capacity, this.results));
            }

            return this.results;
        }
    };
}());

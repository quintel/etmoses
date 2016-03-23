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

    function sampledData(loads) {
        return loads.map(function (y, x) {
            return { x: formatDateFromFrame(loads, x), y: y };
        });
    }

    Transformator.prototype = {
        transform: function (viewAsStacked) {
            var settings, values,
                results = [],
                load    = fetchLoad.call(this),
                data    = this.d3Chart.lastRequestedData;

            load.forEach(function (datum) {
                values   = data[datum.type];
                settings = LoadChartsSettings[datum.type || this.d3Chart.curveType];

                if (values) {
                    results.push({
                        key:     settings.name,
                        type:    datum.type,
                        values:  sampledData(values),
                        area:    viewAsStacked || datum.area,
                        color:   settings.color,
                        visible: settings.visible
                    });
                }
            }.bind(this));

            if (data.capacity && !viewAsStacked) {
                results.push(generateCapacity(data.capacity, results));
            }

            return results;
        }
    };

    function Transformator(d3Chart, load, thisCurrentWeek) {
        this.d3Chart = d3Chart;
        this.load    = load;

        currentWeek  = thisCurrentWeek;
    }

    return Transformator;
}());

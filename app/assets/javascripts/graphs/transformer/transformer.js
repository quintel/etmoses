/*globals I18n,LoadChartsSettings,StrategyHelper*/

var Transformer = (function () {
    'use strict';

    var currentWeek,
        msInWeek     = 6.048e+8,
        chartLengths = {
            long: 35040,
            short: 8760,
            annual: 365
        };

    function generateCapacity(data, results, scaling) {
        var capacity = (data.capacity * (data.units || 1.0)),
            extent   = d3.extent(results[0].values, function (d) { return d.x; });

        // scale capacity according to the unit being shown.
        capacity = (capacity * 1000) / scaling.unit.power.multiple;

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

    function createChart(chartType) {
        var anyStrategies = StrategyHelper.anyStrategies();

        return {
            type: chartType,
            area: (!anyStrategies || /_features$/.test(chartType))
        };
    }

    function fetchLoad() {
        if (this.settings.load) {
            return this.settings.load;
        } else if (StrategyHelper.anyStrategies()) {
            return window.currentTree.availableCharts().map(createChart);
        } else {
            return window.currentTree.basicCharts.map(createChart);
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

    function formatYvalue(y) {
        if (this.scaling) {
            return ((y * 1000) / this.scaling.unit.power.multiple);
        } else {
            return y;
        }
    }

    function setCoords(loads) {
        return loads.map(function (y, x) {
            return { x: formatDateFromFrame(loads, x), y: formatYvalue.call(this, y) };
        }.bind(this));
    }

    function isStaticLoadOrTotal() {
        return (this.settings.load || this.settings.view_as === 'total');
    }

    function isShown(chartType) {
        var index,
            type = this.settings.view_carrier;

        if (this.settings.strategies && StrategyHelper.anyStrategies()) {
            index = window.currentTree.basicCharts.indexOf(type);
            type  = window.currentTree.featureCharts[index];
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
            values:  setCoords.call(this, values),
            area:    datum.area,
            color:   settings.color,
            visible: settings.visible
        };
    }

    function setLoadsPerTech(values) {
        var tech;

        for (tech in values.tech_loads) {
            if (!LoadChartsSettings[tech]) {
                LoadChartsSettings[tech] = { visible: true };
            }

            this.results.push({
                key:     I18n.translations.en.inputs[tech],
                type:    tech,
                values:  setCoords.call(this, values.tech_loads[tech]),
                area:    (this.settings.view_as === 'stacked'),
                color:   $(".technologies.hidden span." + tech).data('color'),
                visible: LoadChartsSettings[tech].visible
            });
        }
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
        transform: function (d3Chart) {
            this.results  = [];
            this.data     = d3Chart.lastRequestedData;
            this.settings = d3Chart.settings;
            this.scaling  = d3Chart.scaling;

            currentWeek   = d3Chart.currentWeek;

            fetchLoad.call(this).forEach(setLoad.bind(this));

            if (this.data.capacity && this.settings.view_as === 'total') {
                this.results.push(
                    generateCapacity(this.data, this.results, this.scaling)
                );
            }

            return this.results;
        }
    };
}());

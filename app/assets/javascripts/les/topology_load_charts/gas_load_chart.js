var GasLoadChart = (function () {
    "use strict";

    function loadChartData(profile, week) {
        var totals = [];

        profile.values.forEach(function(item) {
            totals.push({
                type: item.type,
                name: item.name,
                area: true,
                values: { total: LoadSlicer.slice(item.load, week) }
            });
        });

        return totals;
    }

    function render(profile) {
        var data = loadChartData.call(this, profile);

        $(this.scope).empty();

        this.loadChart = new D3LoadChart(this.scope, this.data.curveType, {
            load: data,
            dateCallback: null, //renderHighResolutionPreview.bind(this),
            width: 450
        });
        this.loadChart.render(data);

        // Please remove this
        $(this.scope).find("svg").attr("height", 600)
    }

    GasLoadChart.prototype = {
        draw: function () {
            Ajax.json(this.data.url,
                { resolution: this.resolution }, render.bind(this));
        }
    };

    function GasLoadChart(scope, data) {
        this.scope = scope;
        this.data  = data;
    }

    return GasLoadChart;
}());

var GasLoadChart = (function () {
    "use strict";

    var spinner;

    function loadChartData(profile, week) {
        var totals = [];

        profile.values.forEach(function(item) {
            totals.push({
                type: item.type,
                name: item.name,
                area: false,
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
        $(this.scope).find("svg").attr("height", 600);

        spinner.hide();
    }

    GasLoadChart.prototype = {
        draw: function () {
            spinner = $(this.scope).parents('.chart-holder')
                          .find('.loading-spinner');

            spinner.show();

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

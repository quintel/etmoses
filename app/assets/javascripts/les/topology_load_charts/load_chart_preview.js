/*globals D3LoadChart */
var LoadChartPreview = (function () {
    "use strict";

    function sliceLoad(loads, week) {
        var chunkSize;

        if (week && week !== 0) {
            chunkSize = Math.floor(loads.length / 52);

            loads = loads.slice((week - 1) * chunkSize, week * chunkSize);
        }

        return loads;
    }

    function loadChartData(profile, week) {
        var data = {
            type: this.curveData.curveType || profile.curveType || 'default',
            name: profile.name || profile.key,
            area: true
        };

        data[data.type] = { total: sliceLoad(profile.values, week) };

        return data;
    }

    function resolution(week) {
        return {
            resolution: (week === 0 ? 'low' : 'high')
        };
    }

    function renderHighResolutionPreview(week) {
        $.getJSON(this.curveData.url, resolution(week))
            .success(function (profile) {
                this.loadChart.update(loadChartData.call(this, profile, week));
            }.bind(this));
    }

    function render(profile) {
        $(this.context).empty();

        this.loadChart = new D3LoadChart(this.renderClass, this.curveData.curveType, {
            load:         loadChartData.call(this, profile),
            dateCallback: renderHighResolutionPreview.bind(this),
            width:        this.curveData.width || 1080
        });
        this.loadChart.render(loadChartData.call(this, profile));
    }

    LoadChartPreview.prototype = {
        loadChart: null,
        preview: function () {
            $.getJSON(this.curveData.url,
                { resolution: this.resolution }).success(render.bind(this));
        }
    };

    function LoadChartPreview(context) {
        this.resolution  = 'low';
        this.context     = context;
        this.curveData   = $(context).data();
        this.renderClass = "." + $(context).attr("class").replace(/\s/g, '.');
    }

    return LoadChartPreview;
}());

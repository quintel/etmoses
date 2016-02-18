/*globals D3LoadChart */
var LoadChartPreview = (function () {
    "use strict";

    function loadChartData(profile) {
        var data = {
            type: this.curveData.curveType || profile.curveType || 'default',
            name: profile.name || profile.key,
            area: true
        };

        data[data.type] = profile.values;

        return data;
    }

    function renderHighResolutionPreview() {
        $.getJSON(this.curveData.url, { resolution: 'high' })
            .success(function (profile) {
                this.loadChart.update(loadChartData.call(this, profile));
            }.bind(this));
    }

    function render(profile) {
        $(this.context).empty();

        this.loadChart = new D3LoadChart(this.renderClass, this.curveData.curveType, {
            load:         loadChartData.call(this, profile),
            dateCallback: renderHighResolutionPreview.bind(this),
            width:        1140
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

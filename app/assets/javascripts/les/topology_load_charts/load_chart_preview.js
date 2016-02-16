var LoadChartPreview = (function () {
    "use strict";

    function loadChartData(profile) {
        return [{
            values: profile.values,
            name:   profile.name || profile.key,
            area:   true
        }];
    }

    function renderHighResolutionPreview(value) {
        this.resolution = (value === 0 ? 'low' : 'high');

        $.getJSON(this.curveData.url, { resolution: this.resolution })
            .success(function(data) {
                this.loadChart.data = loadChartData(data);
                this.loadChart.updateGraph();
            }.bind(this));
    }

    function render(profile) {
        $(this.context).empty().html("<svg></svg>");

        this.loadChart = new LoadChart(loadChartData(profile), null, this.curveData.curveType);
        this.loadChart.render(this.renderClass, renderHighResolutionPreview.bind(this));
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
        this.renderClass = "." + $(context).attr("class")
                            .replace(/\s/g, '.') + " svg";
    }

    return LoadChartPreview;
}());

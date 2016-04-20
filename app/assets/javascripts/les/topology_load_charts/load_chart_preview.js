/*globals D3LoadChart */

var LoadChartPreview = (function () {
    "use strict";

    function loadChartData(profile, week) {
        return[ {
            type: this.curveData.curveType || profile.curveType || 'default',
            name: profile.name || profile.key,
            values: { total: LoadSlicer.slice(profile.values, week) },
            area: true
        } ];
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

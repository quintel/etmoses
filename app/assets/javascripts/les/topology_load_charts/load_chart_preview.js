/*globals D3LoadChart */

var LoadChartPreview = (function () {
    "use strict";

    function loadChartData(week) {
        return[ {
            type: this.curveData.curveType || this.profile.curveType || 'default',
            name: this.profile.name || this.profile.key,
            values: { total: LoadSlicer.slice(this.profile.values, week) },
            area: true
        } ];
    }

    function renderHighResolutionPreview(week) {
        this.profile = $.extend(true, {}, this.profile);

        this.loadChartData = loadChartData.call(this, week);
        this.loadChart.settings.load = this.loadChartData;

        this.loadChart.update(this.loadChartData);
    }

    function render(profile) {
        $(this.context).empty();

        this.profile       = $.extend(true, {}, profile);
        this.loadChartData = loadChartData.call(this, 1);
        this.loadChart     = new D3LoadChart(
            this.renderClass,
            this.curveData.curveType, {
                load:         this.loadChartData,
                width:        this.curveData.width || 1080,
                dateCallback: renderHighResolutionPreview.bind(this)
            }
        );
        this.loadChart.render(loadChartData);
    }

    LoadChartPreview.prototype = {
        loadChart: null,
        preview: function () {
            $.getJSON(this.curveData.url).success(render.bind(this));
        }
    };

    function LoadChartPreview(context) {
        this.context     = context;
        this.curveData   = $(context).data();
        this.renderClass = "." + $(context).attr("class").replace(/\s/g, '.');
    }

    return LoadChartPreview;
}());

/*globals CSV,LoadChart,LoadChartHelper,StrategyHelper*/
var ChartShower = (function () {
    'use strict';

    function toggleSelectedNode() {
        d3.selectAll(".overlay circle, .overlay text").style("opacity", 0.3);
        d3.selectAll(".overlay text").style({
            "font-weight": "normal",
            "text-decoration": "none"
        });

        d3.select(".overlay g.node.n" + this.id).select("circle").style("opacity", 1.0);
        d3.select(".overlay g.node.n" + this.id).select("text").style({
            "opacity": 1.0,
            "font-weight": "bold"
        });
    }

    function showTechnologies() {
        var techTab = $('#technologies .row-fluid[data-node="' + this.name + '"]');
        if (techTab.length > 0) {
            techTab.show();
            $(".technologies-button").parent().removeClass("disabled");
            $(".nav-tabs li a[href='#technologies']").removeClass("disabled-tab");
        } else {
            $(".technologies-button").parent().addClass("disabled");
            $(".nav-tabs li a[href='#technologies']").addClass("disabled-tab");
        }
    }

    function downloadLoad() {
        var loads      = [],
            chartTypes = ['load', 'load_strategies', 'gas', 'gas_strategies'];

        chartTypes.forEach(function (chartType) {
            if (this[chartType]) {
                [chartType].concat(this[chartType]).forEach(function (value, i) {
                    if (loads[i]) {
                        loads[i] += (','  + value);
                    } else {
                        loads[i] = value;
                    }
                });
            }
        }.bind(this));

        CSV.download(loads.join("\n"), (this.name + ' Curve.csv'), "data:text/csv;charset=utf-8");
    }

    function enableCsvDownloadCurveButton() {
        var self = this,
            downloadBtn = $('li a.download-curve');

        downloadBtn.parent().removeClass("disabled");
        downloadBtn.text("Download curve for '" + this.name + "'");

        downloadBtn.off('click').on('click', function (event) {
            event.preventDefault();

            downloadLoad.call(self);
        });
    }

    function setHeader() {
        $("h1 span").removeClass("hidden");
        $("h1 span.current-chart").text(this.name);

        enableCsvDownloadCurveButton.call(this);
    }

    function toggleDomParts() {
        $('#technologies .row-fluid, p.info').hide();
        showTechnologies.call(this);
        setHeader.call(this);
        toggleSelectedNode.call(this);
    }

    function addNewLoadChartPlatform(d) {
        var load,
            loadChartClass = ('.' + this.uniqueId + ' svg'),
            loadPlatform = $("<div>").addClass(this.uniqueId).addClass("chart");

        loadPlatform.html('<svg></svg>');

        $(".load-graph").prepend(loadPlatform);

        if (StrategyHelper.anyStrategies()) {
            load = [{ values: d.load_strategies, name: 'Load (with strategies)', area: true, type: 'load_strategies' },
                    { values: d.load,            name: 'Load', area: false, type: 'load' },
                    { values: d.gas_strategies,  name: 'Gas (with strategies)', area: true, type: 'gas_strategies' },
                    { values: d.gas,             name: 'Gas', area: false, type: 'gas' }];
        } else {
            load = [{ values: d.load, name: 'Load', area: true, type: 'load' },
                    { values: d.gas,  name: 'Gas',  area: true, type: 'gas' }];
        }

        new LoadChart(load, d.capacity, 'default').render(loadChartClass);
    }

    function showOrLoadPlatform() {
        if (this.existingLoadPlatform.length > 0) {
            this.existingLoadPlatform.show();

            LoadChartHelper.updateBrush(this.id);
            LoadChartHelper.toggleCapacity(this.id);
        } else {
            addNewLoadChartPlatform.call(this, this.nodeData);
            LoadChartHelper.updateBrush(this.id);
        }

        toggleDomParts.call(this.nodeData);
    }

    function showLoadChart() {
        showOrLoadPlatform.call(this);
        LoadChartHelper.reloadChart(this.id);
    }

    ChartShower.prototype = {
        show: function () {
            if (this.nodeData === undefined) {
                return false;
            }

            this.id = this.nodeData.id;
            this.uniqueId = ("chart-id-" + this.id);
            this.existingLoadPlatform = $(".load-graph ." + this.uniqueId);

            $(".load-graph .chart").hide();
            showLoadChart.call(this);
        },

        reload: function () {
            if (LoadChartHelper.forceReload) {
                $(".load-graph .chart").remove();
                LoadChartHelper.forceReload = false;
            }
            return this;
        }
    };

    function ChartShower(treeChart, nodeData) {
        this.treeChart = treeChart;
        this.nodeData  = nodeData;
    }

    return ChartShower;
}());

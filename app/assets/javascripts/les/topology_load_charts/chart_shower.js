/*globals CSV,D3LoadChart*/
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

    function changeViewOfD3(e) {
        var d3Chart = window.currentTree.d3Chart,
            attrName = $(e.target).attr('name');

        if (attrName === 'view_as') {
            d3Chart.view('view_as', $(e.target).val()).update();
        } else {
            d3Chart.view(attrName, $(e.target).prop('checked')).update();
        }
        updateChartViewInputs.call(this);
    }

    function updateChartViewInputs() {
        var viewAs = $("select.chart-view"),
            showViewAs = !((this.load && this.load.tech_loads) ||
                           (this.gas  && this.gas.tech_loads));

        if (viewAs.val() === 'total') {
            $(".chart-view[type='checkbox']").bootstrapToggle('disable');
            viewAs.prop('disabled', showViewAs);
        } else {
            toggleChartView('electricity', this.gas && this.gas.total);
            toggleChartView('strategies', StrategyHelper.anyStrategies());
        }
    }

    function toggleChartView(name, predicate) {
       $(".chart-view[name='" + name + "']")
           .bootstrapToggle(predicate ? 'enable' : 'disable');
    }

    function toggleDomParts() {
        $('#technologies .row-fluid, p.info').hide();
        $(".load-graph-wrapper a[href='#load']").tab('show');
        $("select.load-date").removeClass("hidden");

        $('.chart-view').on('change', changeViewOfD3.bind(this));

        showTechnologies.call(this);
        setHeader.call(this);
        toggleSelectedNode.call(this);
    }

    function addNewLoadChartPlatform() {
        var loadGraphClass = ".load-graph .chart";

        if ($(loadGraphClass).length > 0) {
            window.currentTree.d3Chart.update(this.nodeData);
        } else {
            $(".load-graph").prepend($("<div/>").addClass("chart"));

            window.currentTree.d3Chart.render(this.nodeData);
        }
    }

    function renderLoadChart() {
        if (isValidNodeData.call(this)) {
            addNewLoadChartPlatform.call(this);
        } else {
            window.currentTree.update();
        }
    }

    function isValidNodeData() {
        var d = this.nodeData;

        return (d.load && d.load.total && d.load.total.length) ||
               (d.gas && d.gas.total && d.gas.total.length);
    }

    ChartShower.prototype = {
        show: function () {
            if (this.nodeData === undefined) {
                return false;
            }

            // This is currently not desired due to the fact that
            // congestion is not showing up correctly.
            //
            // See: https://github.com/quintel/etmoses/issues/1026
            //
            // window.currentTree.addNode(this.nodeData.name);
            //
            renderLoadChart.call(this, this.nodeData);
            toggleDomParts.call(this.nodeData);
            updateChartViewInputs.call(this.nodeData);
        }
    };

    function ChartShower(treeChart, nodeData) {
        this.treeChart = treeChart;
        this.nodeData  = nodeData;
    }

    return ChartShower;
}());

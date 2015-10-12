/*globals StrategyHelper,ErrorDisplayer,TreeFetcher,TreeGraph*/
var TopologyTree = (function () {
    'use strict';

    function updateLoadChart(treeDataWithStrategies) {
        this.treeGraph.strategyToggler.updateLoadChartWithStrategies(treeDataWithStrategies);
        this.treeGraph.initialStrategyCallDone = true;
        this.treeGraph.showGraph();
    }

    function setInitialLoadChart(treeData) {
        $("#collapse-stakeholders select").prop('disabled', false);

        if (!StrategyHelper.anyStrategies()) {
            this.treeGraph.initialStrategyCallDone = true;
            this.treeGraph.strategyToggler.toggleLoading();
        }

        this.treeGraph.initialCallDone = true;
        this.treeGraph.showGraph(treeData.graph);
    }

    TopologyTree.prototype = {
        showTree: function () {
            $("a.dropdown-toggle").first().addClass("disabled");
            $("#collapse-stakeholders select").prop('disabled', true);

            this.treeGraph.strategyToggler.toggleLoading();
            this.treeGraph.strategyToggler.setStrategies();

            new TreeFetcher(this.url).fetch({}, setInitialLoadChart.bind(this));

            if (StrategyHelper.anyStrategies()) {
                new TreeFetcher(this.url).fetch({
                    strategies: StrategyHelper.getStrategies()
                }, updateLoadChart.bind(this));
            }
        }
    };

    function TopologyTree(url, container) {
        this.url = url;
        this.container = container;
        this.treeGraph = new TreeGraph(url, container);
    }

    return TopologyTree;
}());

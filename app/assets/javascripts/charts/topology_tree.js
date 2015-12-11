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

        // Temporary hacky solution to install gas loads on to endpoint nodes
        // for display in the load chart.
        var gasLoads = ETHelper.loadsFromTree(treeData.networks.gas);

        ETHelper.eachNode([treeData.networks.electricity], function(node) {
            if (gasLoads.hasOwnProperty(node.name)) {
                node.gasLoad = gasLoads[node.name];
            }
        });

        this.treeGraph.initialCallDone = true;
        this.treeGraph.showGraph(treeData.networks.electricity);
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

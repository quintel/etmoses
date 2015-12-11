/*globals StrategyHelper,ErrorDisplayer,TreeFetcher,TreeGraph*/
var TopologyTree = (function () {
    'use strict';

    function updateLoadChart(treeDataWithStrategies) {
        new StatusUpdater("Done calculating load with applied strategies").append();

        setTimeout(function () {
            this.treeGraph.strategyToggler.updateLoadChartWithStrategies(treeDataWithStrategies);
            this.treeGraph.initialStrategyCallDone = true;
            this.treeGraph.showGraph();
        }.bind(this), 1000);
    }

    function setInitialLoadChart(treeData) {
        new StatusUpdater("Done calculating load").append();

        $("#collapse-stakeholders select").prop('disabled', false);

        setTimeout(function () {
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
        }.bind(this), 1000);
    }

    TopologyTree.prototype = {
        showTree: function () {
            $("a.dropdown-toggle").first().addClass("disabled");
            $("#collapse-stakeholders select").prop('disabled', true);

            this.treeGraph.strategyToggler.toggleLoading();
            this.treeGraph.strategyToggler.setStrategies();

            new StatusUpdater("Calculating load", 1).append();
            new TreeFetcher(this.url).fetch({}, setInitialLoadChart.bind(this));

            if (StrategyHelper.anyStrategies()) {
                new StatusUpdater("Calculating load with applied stategies", 1).append();
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

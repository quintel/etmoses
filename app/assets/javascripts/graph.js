/*globals D3LineGraph,D3StackedBarGraph,D3GasLoadChart,D3HeatLoadChart,
D3BaseStaticLoadChart,D3ProfileChart*/

window.graphs = {};

var Graph = (function () {
    'use strict';

    function getGraph() {
        return {
            line:              D3LineGraph,
            stacked_bar:       D3StackedBarGraph,
            gas_load_chart:    D3GasLoadChart,
            heat_load_chart:   D3HeatLoadChart,
            static_load_chart: D3BaseStaticLoadChart,
            profile_chart:     D3ProfileChart
        }[this.data.type];
    }

    function drawGraph(Graph) {
        var graphId = "g" + new Date().getTime(),
            graph   = new Graph(this.scope, this.data);

        $(this.scope).attr('id', graphId);
        window.graphs[graphId] = graph;

        // If the graph is explicitly stalled from rendering than halt the
        // render process. If not, we asume that the chart can automatically
        // render upon page load.
        if (!this.data.stalled) {
            graph.draw();
        }

        return graph;
    }

    Graph.prototype = {
        render: function () {
            var graph,
                Graph = getGraph.call(this);

            if (Graph) {
                graph = drawGraph.call(this, Graph);
            } else {
                throw "No chart available for " + this.data.type;
            }

            return graph;
        }
    };

    function Graph(scope) {
        this.scope    = scope;
        this.defaults = { type: 'line', interpolate: 'linear' };
        this.data     = $.extend(this.defaults, $(this.scope).underscorizedData());
    }

    return Graph;
}());

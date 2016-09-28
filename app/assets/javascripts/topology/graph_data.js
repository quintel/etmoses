Topology.GraphData = (function () {
    'use strict';

    var data = {
        name: "HV",
        stakeholder: "aggregator"
    };

    GraphData.prototype = {
        dump: function () {
            var dumpedData = (this.graph || data);

            dumpedData.focus = true;

            return dumpedData;
        },

        update: function (data) {
            var updateData = $.extend({}, data);

            ETHelper.eachNode([updateData], function (node) {
                delete node.parent;
                delete node.parentId;
                delete node.childIndex;
                delete node.focus;
            });

            this.scope.text(JSON.stringify(updateData));
        }
    }

    function GraphData(scope) {
        this.scope = scope.find("#topology_graph");
        this.graph = scope.data('graph');
    }

    return GraphData;
}());

/*globals ETHelper,NetworkToTree,Topology*/

Topology.NetworkToTree = (function () {
    'use strict';

    return {
        toTree: function (data) {
            var chartType, carrier, loads, techLoads;

            for (chartType in data) {
                for (carrier in data[chartType].networks) {
                    techLoads = data[chartType].tech_loads[carrier];
                    loads     = ETHelper.loadsFromTree(data[chartType].networks[carrier]);

                    ETHelper.eachNode([this.treeData], function (node) {
                        node[carrier + '_' + chartType] = {
                            total: loads[node.name],
                            tech_loads: techLoads[node.name]
                        };
                    });
                }
            }

            return this.treeData;
        }
    };
}());

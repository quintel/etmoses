/*globals ETHelper,Topology,Validator*/

Topology.Validator = (function () {
    'use strict';

    return {
        isValid: function (graph) {
            var valid = true,
                lastInvalidNode;

            ETHelper.eachNode([graph.data], function (node) {
                if (!node.name || node.name === '') {
                    node.errors = { name: "name can't be blank" };

                    lastInvalidNode = node;

                    valid = false;
                } else {
                    delete node.errors;
                }
            });

            graph.update(lastInvalidNode || graph.data);
            window.TopologyEditor.graphData.setData(graph.data);

            if (lastInvalidNode) {
                window.TopologyEditor.graphEditor.focusId = lastInvalidNode.id;
                window.TopologyEditor.form.show(lastInvalidNode);
                window.TopologyEditor.nodeInterface.reposition();
            }


            return valid;
        }
    };
}());

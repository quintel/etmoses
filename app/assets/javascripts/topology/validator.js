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

            if (lastInvalidNode) {
                lastInvalidNode.focus = true;

                window.TopologyEditor.form.show(lastInvalidNode);
            }

            graph.update();
            window.TopologyEditor.graphData.update(graph.data);

            return valid;
        }
    }
}());

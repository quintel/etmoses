var ETHelper = (function () {
    'use strict';

    return {
        groupBy: function (elements, key) {
            var grouped = {};

            elements.forEach(function (element) {
                if (!grouped.hasOwnProperty(element[key])) {
                    grouped[element[key]] = [];
                }

                grouped[element[key]].push(element);
            });

            return grouped;
        },

        eachNode: function (nodes, iterator) {
            nodes.forEach(function (node) {
                iterator.call(this, node);

                if (node.children && node.children.length) {
                    ETHelper.eachNode(node.children, iterator);
                }

                if (node._children && node._children.length) {
                    ETHelper.eachNode(node._children, iterator);
                }
            });
        },

        loadsFromTree: function (tree) {
            var loads = {};

            ETHelper.eachNode([tree], function (node) {
                loads[node.name] = node.load;
            });

            return loads;
        }
    };
}());

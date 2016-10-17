/*globals ETHelper,GraphData,Topology*/

Topology.GraphData = (function () {
    'use strict';

    var data = {
        name: "HV",
        stakeholder: "aggregator"
    };

    function findChild(el, focusId) {
        if (focusId === 1) {
            return el;
        }

        var foundChild;

        function loopChildren(el) {
            var i, child;

            if (el.children && el.children.length > 0) {
                for (i = 0; i < el.children.length; i += 1) {
                    child = el.children[i];

                    if (child.id === focusId) {
                        foundChild            = child;
                        foundChild.childIndex = i;
                        foundChild.parentId   = el.id;

                        break;
                    } else {
                        if (child.children) {
                            loopChildren(child);
                        }

                        if (foundChild) {
                            break;
                        }
                    }
                }
            }
        }

        loopChildren(el);

        return foundChild;
    }

    GraphData.prototype = {
        add: function (parentId) {
            var node    = findChild(this.graph, parentId),
                newNode = {
                    name: "",
                    stakeholder: "aggregator"
                };

            if (node.children) {
                node.children.push(newNode);
            } else {
                node.children = [newNode];
            }

            this.setData(this.graph);

            return newNode;
        },

        update: function (id, formData) {
            var child = findChild(this.graph, id);

            $.extend(child, formData);

            this.setData(this.graph);
        },

        deleteNode: function (id) {
            var confirmDeletion = true,
                child           = findChild(this.graph, id),
                parent          = findChild(this.graph, child.parentId);

            if (child.children && child.children.length > 0) {
                confirmDeletion = confirm("Are you sure you want to delete this node?");
            }

            if (confirmDeletion) {
                parent.children.splice(child.childIndex, 1);
            }

            this.setData(this.graph);

            return confirmDeletion;
        },

        setData: function (data) {
            var updateData = $.extend({}, data);

            ETHelper.eachNode([updateData], function (node) {
                delete node.parent;
                delete node.parentId;
                delete node.childIndex;
            });

            this.scope.text(JSON.stringify(updateData));
        }
    };

    function GraphData(scope) {
        this.scope = scope.find(".topology-graph");
        this.graph = scope.data('graph') || data;
    }

    return GraphData;
}());

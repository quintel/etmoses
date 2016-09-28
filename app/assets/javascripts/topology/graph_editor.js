/* Basic class draws D3 svg element */

Topology.GraphEditor = (function () {
    'use strict';

    function deleteChild(el, child) {
        var confirmDeletion = true,
            parent = findChild(el, child.parentId);

        if (child.children && child.children.length > 0) {
            confirmDeletion = confirm("Are you sure you want to delete this node?");
        }

        if (confirmDeletion) {
            parent.children.splice(child.childIndex, 1);
        }

        return confirmDeletion;
    }

    function findChild(el, focusId) {
        if (focusId === 1) {
            return el;
        }

        var i, child, foundChild;

        function loopChildren(el) {
            if (el.children) {
                for (var i = 0; i < el.children.length; i++) {
                    child = el.children[i];

                    if (child.id === focusId) {
                        foundChild            = child;
                        foundChild.childIndex = i;
                        foundChild.parentId   = el.id;

                        break;
                    }

                    if (child.children && child.children.length > 0) {
                        loopChildren(child);
                    }
                }
            }
        }

        loopChildren(el);

        return foundChild;
    }

    function deleteNode(el, focusId) {
        var isDeleted = true,
            child = findChild(el, focusId);

        return deleteChild(el, child);
    }

    function keydown() {
        if (this.focusId !== 1) {
            switch (d3.event.keyCode) {
                case 46: {
                    if (deleteNode(this.graph.data, this.focusId)) {
                        this.graph.update();

                        window.TopologyEditor.graphData.update(this.graph.data);
                    }
                    break;
                }
            }
        }
    }

    GraphEditor.prototype = {
        initialize: function () {
            this.graph = new Topology.EditorGraph(this.scope, this.graphData.dump());
            this.graph.draw();

            d3.select(window)
                .on("keydown", keydown.bind(this));
        },

        addNode: function (d) {
            var newNode = {
                name: "",
                stakeholder: "aggregator",
                focus: true
            };

            // Unfocus every child
            ETHelper.eachNode([this.graph.data], function (child) {
                child.focus = false;
            });

            // Add new child
            if (d.children) {
                d.children.push(newNode);
            } else {
                d.children = [newNode];
            }

            this.graph.update();

            window.TopologyEditor.graphData.update(this.graph.data);
            window.TopologyEditor.form.show(newNode);
        },

        updateNode: function (d) {
            var child = findChild(this.graph.data, this.focusId);

            $.extend(child, d);

            window.TopologyEditor.graphData.update(this.graph.data);
        }
    };

    function GraphEditor(scope, graphData) {
        this.scope     = scope.find('.graph-editor')[0];
        this.graphData = graphData;
        this.focusId   = -1;
    }

    return GraphEditor;
}());

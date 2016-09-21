/* Basic class draws D3 svg element */

Topology.GraphEditor = (function () {
    'use strict';

    function deleteChild(el, child, index) {
        var confirmDeletion = true;

        if (child.children && child.children.length > 0) {
            confirmDeletion = confirm("Are you sure you want to delete this node?");
        }

        if (confirmDeletion) {
            el.children.splice(index, 1);
            el.focus = true;
        }

        return confirmDeletion;
    }

    function findChild(el, focusId) {
        var foundChild = el;

        if (el.children) {
            el.children.forEach(function (child, index) {
                if (child.id === focusId) {
                    foundChild            = child;
                    foundChild.childIndex = index;
                    foundChild.parent     = el;

                    return false;
                }

                if (child.children && child.children.length > 0) {
                    findChild(child, focusId);
                }
            });
        }

        return foundChild;
    }

    function deleteNode(el, focusId) {
        var isDeleted = true,
            child = findChild(el, focusId);

        return deleteChild(child.parent, child, child.childIndex);
    }

    function keydown() {
        if (this.focusId !== 1) {
            switch (d3.event.keyCode) {
                case 8:
                case 46: {
                    if (deleteNode(this.graph.data, this.focusId)) {
                        this.graph.update();
                    }
                    break;
                }
            }
        }
    }

    GraphEditor.prototype = {
        initialize: function () {
            this.graph = new Topology.EditorGraph(this.scope, {
                name: "HV",
                stakeholder: "aggregator",
                focus: true
            });

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
            ETHelper.eachNode([this.graph.data],
                function (child) { child.focus = false; });

            // Add new child
            if (d.children) {
                d.children.push(newNode);
            } else {
                d.children = [newNode];
            }

            this.graph.update();

            window.TopologyEditor.form.show(newNode);
        },

        updateNode: function (d) {
            $.extend(findChild(this.graph.data, this.focusId), d);
        }
    };

    function GraphEditor(scope) {
        this.scope   = scope.find('.graph-editor')[0];
        this.focusId = -1;
    }

    return GraphEditor;
}());

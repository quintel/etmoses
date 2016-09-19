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
    }

    function deleteNode(el, focusId) {
        el.children.forEach(function (child, index) {
            if (child.id === focusId) {
                deleteChild(el, child, index);

                return false;
            }

            if (child.children && child.children.length > 0) {
                deleteNode(child, focusId);
            }
        });
    }

    function keydown() {
        if (this.focusId !== 1) {
            switch (d3.event.keyCode) {
                case 8:
                case 46: {
                    deleteNode(this.graph.root, this.focusId);
                    this.graph.update();
                    break;
                }
            }
        }
    }

    GraphEditor.prototype = {
        initialize: function () {
            this.graph = new Topology.EditorGraph(this.scope);
            this.graph.draw();

            d3.select(window)
                .on("keydown", keydown.bind(this));
        },

        addNode: function (d) {
            if (!(d.children && d.children.length && d.children.length > 0)) {
                d.children = [];
            }

            ETHelper.eachNode([this.graph.root],
                function (child) { child.focus = false; });

            d.children.push({ name: "New node", focus: true });

            this.graph.update();

            window.TopologyEditor.form.show(d);
        }
    };

    function GraphEditor(scope) {
        this.scope   = scope.find('.graph-editor')[0];
        this.focusId = -1;
    }

    return GraphEditor;
}());

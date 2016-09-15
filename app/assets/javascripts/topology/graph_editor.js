/*globals confirm,ETHelper,GraphEditor,Topology*/

Topology.GraphEditor = (function () {
    'use strict';

    function keydown() {
        if (this.focusId !== 1 && d3.event.keyCode === 46) {
            this.deleteNode();
        }
    }

    GraphEditor.prototype = {
        initialize: function () {
            this.graph = new Topology.EditorGraph(this.scope, this.graphData.graph);
            this.graph.draw();

            d3.select(window)
                .on("keydown", keydown.bind(this));
        },

        deleteNode: function () {
            if (this.graphData.deleteNode(this.focusId)) {
                this.graph.update(this.graphData.graph);
                this.focusId = 1;

                window.TopologyEditor.form.markAsEditing();
                window.TopologyEditor.nodeInterface.reposition();
            }
        },

        addNode: function () {
            var newNode = this.graphData.add(this.focusId);

            this.graph.update(newNode);
            this.focusId = newNode.id;

            window.TopologyEditor.form.show(newNode);
            window.TopologyEditor.form.markAsEditing();
            window.TopologyEditor.nodeInterface.reposition();
        },

        updateNode: function (formData) {
            this.graphData.update(this.focusId, formData);

            window.TopologyEditor.form.markAsEditing();
        }
    };

    function GraphEditor(scope, graphData) {
        this.scope     = scope.find('.graph-editor')[0];
        this.graphData = graphData;
        this.focusId   = 1;
    }

    return GraphEditor;
}());

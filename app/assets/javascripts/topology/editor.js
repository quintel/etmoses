var Topology = {};

Topology.Editor = (function () {
    'use strict';

    Editor.prototype = {
        initialize: function () {
            this.yamlEditor.initialize();
            this.graphEditor.initialize();
            this.form.initialize();
            this.editorSwitcher.initialize();
        },

        focusNode: function (d) {
            this.form.show(d);
            this.graphEditor.focusId = d.id;
        }
    };

    function Editor(scope) {
        this.scope          = scope;
        this.graphData      = new Topology.GraphData(this.scope);
        this.form           = new Topology.Form(this.scope);
        this.graphEditor    = new Topology.GraphEditor(this.scope, this.graphData);
        this.yamlEditor     = new Topology.YamlEditor(this.scope, this.graphData);
        this.editorSwitcher = new Topology.EditorSwitcher(this.scope,
            [this.graphEditor, this.yamlEditor]);
    }

    return Editor;
}());

$(document).on('page:change', function () {
    var form,
        graphEditor = $('.graph-topology');

    if (graphEditor.length > 0) {
        window.TopologyEditor = new Topology.Editor(graphEditor);
        window.TopologyEditor.initialize();
    }
});

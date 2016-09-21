var Topology = {};

Topology.Editor = (function () {
    'use strict';

    Editor.prototype = {
        initialize: function (data) {
            this.graphEditor.initialize();
            this.form.initialize();
        }
    };

    function Editor(scope) {
        this.scope       = scope;
        this.graphEditor = new Topology.GraphEditor(this.scope);
        this.form        = new Topology.Form(this.scope);
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

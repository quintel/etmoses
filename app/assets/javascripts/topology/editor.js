var Topology = {};

Topology.Editor = (function () {
    'use strict';

    Editor.prototype = {
        initialize: function (data) {
            this.graphEditor.draw();
        }
    };

    function Editor(scope) {
        this.scope       = scope;
        this.graphEditor = new Topology.GraphEditor(this.scope);
    }

    return Editor;
}());

$(document).on('page:change', function () {
    var form,
        graphEditor = $('.graph-topology');

    if (graphEditor.length > 0) {
        new Topology.Editor(graphEditor).initialize();
    }
});

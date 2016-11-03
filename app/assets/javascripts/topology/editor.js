/*globals Editor*/

var Topology = {};

Topology.Editor = (function () {
    'use strict';

    Editor.prototype = {
        initialize: function () {
            this.graphEditor.initialize();
            this.nodeInterface.initialize();
            this.form.initialize();
            this.graphData.setData(this.graphData.graph);

            this.scope.parents("form").on("submit", function () {
                var valid = Topology.Validator.isValid(this.graphEditor.graph);

                if (!valid) {
                    $(this).find("input[type=submit]").removeClass("disabled");
                    $(this).find("span.wait").addClass("hidden");
                }

                return valid;
            }.bind(this));
        }
    };

    function Editor(scope) {
        this.scope         = scope;
        this.isRemote      = scope.parents('form').data('remote');
        this.graphData     = new Topology.GraphData(this.scope);
        this.graphEditor   = new Topology.GraphEditor(this.scope, this.graphData);
        this.nodeInterface = new Topology.NodeInterface(this.scope);
        this.form          = new Topology.Form(this.scope);
    }

    return Editor;
}());

$(document).on('page:change', function () {
    'use strict';

    var graphEditor = $('.graph-topology');

    if (graphEditor.length > 0) {
        window.TopologyEditor = new Topology.Editor(graphEditor);
        window.TopologyEditor.initialize();
    }
});

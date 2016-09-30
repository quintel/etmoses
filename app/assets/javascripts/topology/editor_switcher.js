Topology.EditorSwitcher = (function () {
    'use strict';

    EditorSwitcher.prototype = {
        initialize: function () {
            this.scope.find("a.switch-editor")
                .off('click')
                .on('click', this.switchEditor.bind(this));
        },

        switchEditor: function (e) {
            e.preventDefault();

            this.graphEditorEnabled = !this.graphEditorEnabled;

            this.editors[0].toggle(this.graphEditorEnabled);
            this.editors[1].toggle(!this.graphEditorEnabled);
        }
    }

    function EditorSwitcher(scope, editors) {
        this.scope              = scope;
        this.editors            = editors;
        this.graphEditorEnabled = true;
    }

    return EditorSwitcher;
}());

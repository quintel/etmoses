Topology.YamlEditor = (function () {
    'use strict';

    function onInputChange() {
        var value = this.editor.getSession().getValue(),
            obj   = jsyaml.safeLoad(value);

        this.graphData.update(obj);
        this.textArea.text(value);

        $("a[href='#topology']").addClass("editing");
        this.textArea.parents("form").addClass("editing");
    }

    YamlEditor.prototype = {
        initialize: function () {
            var id         = this.textArea.attr("id"),
                pre        = $("<pre/>").attr("id", id + "_editor"),
                editorWrap = $("<div/>").attr("class", "editor-wrap").append(pre);

            this.textArea.hide();
            this.textArea.data('editor', true);
            this.textArea.after(editorWrap);

            this.editor = ace.edit(id + "_editor");
            this.editor.getSession().setMode("ace/mode/yaml");
            this.editor.setTheme('ace/theme/github');
            this.editor.setHighlightActiveLine(false);
            this.editor.setShowPrintMargin(false);

            this.editor.on('input', onInputChange.bind(this));
        },

        toggle: function (isEnabled) {
            this.scope.toggle(isEnabled);
            this.editor.getSession().setValue(this.graphData.toYAML());
        }
    }

    function YamlEditor(scope, graphData) {
        this.scope     = scope.find(".yaml-editor");
        this.textArea  = this.scope.find("textarea");
        this.graphData = graphData;
    }

    return YamlEditor;
}());

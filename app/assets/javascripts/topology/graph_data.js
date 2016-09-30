Topology.GraphData = (function () {
    'use strict';

    GraphData.prototype = {
        update: function (data) {
            // TODO: FIX ME SO BADLY
            // :( Don't overwrite data plox
            // Format the new data and smack it to YAML
            // Maybe use a different formatter for YAML than Graph?
            this.data = this.format(data);

            this.scope.text(this.toYAML());
        },

        format: function (data) {
            var formatted = $.extend(true, data, {});

            ETHelper.eachNode([formatted], function (node) {
                delete node.parent;
                delete node.parentId;
                delete node.childIndex;
                delete node.focus;
            });

            return formatted;
        },

        toYAML: function () {
            var data = this.format(this.data);

            return jsyaml.safeDump(data);
        },

        toGraph: function () {
            return this.data;
        },

        initializeData: function () {
            var obj = jsyaml.safeLoad(this.scope.text());

            obj.focus = true;

            return obj;
        }
    }

    function GraphData(scope) {
        this.scope = scope.find("textarea#topology_graph");
        this.data  = this.initializeData();
    }

    return GraphData;
}());

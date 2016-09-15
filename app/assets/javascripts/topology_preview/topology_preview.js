$(document).on("page:change", function () {
    'use strict';

    if ($("div.topology-graph").length > 0) {
        new Topology.PreviewGraph(".topology-graph").draw();
    }
});

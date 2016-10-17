$(document).on("page:change", function() {
    'use strict';

    var topologySelect,
        newImportForm = $("form#new_import")

    if (newImportForm.length > 0) {
        topologySelect = newImportForm.find("select#import_topology_template_id");

        function getTopology() {
            $.ajax({
                type: "GET",
                url: "/topology_templates/" + $(this).val() + ".json",
                dataType: "json",
                success: displayPreview
            });
        };

        function displayPreview(data) {
            new Topology.ImportPreviewGraph(".topology-preview .preview-svg", data.graph).draw();
        };

        getTopology.call(topologySelect);
        topologySelect.on('change', getTopology);
    };
});

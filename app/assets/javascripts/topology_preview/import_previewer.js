/*globals Topology*/

$(document).on("page:change", function () {
    'use strict';

    var topologySelect,
        newImportForm = $("form#new_import");

    if (newImportForm.length > 0) {
        topologySelect = newImportForm.find("select#import_topology_template_id");

        topologySelect.on('change', function () {
            $.ajax({
                type: "GET",
                url: "/topology_templates/" + $(this).val() + ".json",
                dataType: "json",
                success: function (data) {
                    new Topology.ImportPreviewGraph(
                        ".topology-preview .preview-svg",
                        data.graph
                    ).draw();
                }
            });
        });

        topologySelect.trigger('change');
    }
});

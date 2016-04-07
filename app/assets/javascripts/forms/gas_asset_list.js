$(document).on('page:change', function () {
    $('form.edit_gas_asset_list').on("ajax:success", function () {
        window.graphs.forEach(function (graph) {
            graph.reload();
        });
    });
});

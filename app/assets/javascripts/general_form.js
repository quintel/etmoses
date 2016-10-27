$(document).on("page:change", function () {
    var tab = new Tab("#general");

    $("div#general form").on('change', function () {
        tab.markAsEditing();
    });
});

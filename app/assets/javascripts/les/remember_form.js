$(document).on("page:change", function () {
    var identifier    = $(".hidden .testing_ground_id").text(),
        localSettings = new LocalSettings(identifier),
        rememberedTab = (localSettings.get('remember_tab') || "#technologies");

    $("ul.nav-tabs li a[role=tab]").off('click').on('click', function () {
        localSettings.set('remember_tab', $(this).attr("href"));
    });

    $("ul.nav-tabs li a[href='" + rememberedTab + "']").tab('show');
});

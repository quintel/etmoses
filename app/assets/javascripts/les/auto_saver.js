var AutoSaver = (function () {
    'use strict';

    function done(formId) {
        this.submitting[formId] = false;
    }

    AutoSaver.prototype = {
        submitting: {},
        submit: function (form) {
            var formId = form.attr('id');

            if (!this.submitting[formId]) {
                this.submitting[formId] = true;

                form.submit();
                form.on("ajax:success", done.bind(this, formId));
            }
        }
    }

    function AutoSaver() { return; }

    return AutoSaver;
}());

$(document).on("page:change", function () {
    window.autoSaver = new AutoSaver();

    var profiles = [
        "#testing_ground_technology_profile",
        "#market_model_interactions",
        "#gas_asset_list_asset_list",
        "#business_case_financials",
        "#topology_name",
        "#testing_ground_name",
        "#testing_ground_behavior_profile_id"
    ];

    $(profiles.join(", ")).on('change', function () {
        window.autoSaver.submit($(this).parents("form"));
    });
});

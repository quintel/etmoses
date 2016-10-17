/*globals Ajax*/

var BusinessCaseValidator = function (form) {
    'use strict';

    return {
        validate: function () {
            var topologyTemplateId    = form.find("#import_topology_template_id").val(),
                marketModelTemplateId = form.find("#import_market_model_template_id").val();

            Ajax.json("/validate_business_case", {
                business_case: {
                    topology_template_id: parseInt(topologyTemplateId, 10),
                    market_model_template_id: parseInt(marketModelTemplateId, 10)
                }
            }, this.warn);
        },

        warn: function (data) {
            $(".business-case-warning").toggleClass("hidden", data.valid);
        }
    };
};

$(document).on("page:change", function () {
    'use strict';

    var form = $("form#new_import"),
        validator = new BusinessCaseValidator(form);

    if (form.length > 0) {
        validator.validate();
        form.find("select").on('change', validator.validate.bind(validator));
    }
});

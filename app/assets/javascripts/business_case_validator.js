var BusinessCaseValidator = function (form) {
    'use strict';

    return {
        validate: function () {
            var data = {
                business_case: {
                    topology_id: $(form).find("select#import_topology_id").val(),
                    market_model_id: $(form).find("select#import_market_model_id").val()
                }
            };

            Ajax.json("/validate_business_case", data, this.warn);
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

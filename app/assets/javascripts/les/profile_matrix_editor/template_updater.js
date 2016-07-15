/*globals ScopeForTemplate*/

var TemplateUpdater = (function () {
    'use strict';

    TemplateUpdater.prototype = {
        update: function () {
            var key         = $(this.technologySelectBox).val(),
                url         = $("#profiles-table").data("renderTemplateUrl"),
                appendScope = new ScopeForTemplate(this.technologySelectBox).getScope();

            if (key) {
                this.scope.find(".add-technology button").addClass("disabled");

                $.ajax({
                    url: url,
                    type: "POST",
                    dataType: 'script',
                    data: {
                        key: key,
                        buffer: $(appendScope).data('compositeValue') || ''
                    }
                });
            }
        }
    };

    function TemplateUpdater(template, technologySelectBox) {
        this.template            = template;
        this.technologySelectBox = technologySelectBox;
        this.scope               = $(this.technologySelectBox).parents('.panel.endpoint');
    }

    return TemplateUpdater;
}());

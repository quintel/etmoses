/*globals CustomPrompt*/

var ReplaceMarketModelForm = (function () {
    'use strict';

    function onShowReplacementForm(e) {
        e.preventDefault();

        $.featherlight($('.prompt.replace_mm'), {
          otherClose: 'a.cancel'
        });
    }

    ReplaceMarketModelForm.prototype = {
        initialize: function () {
            this.context
                .off("click.onSaveAs")
                .on("click.onSaveAs", onShowReplacementForm.bind(this));
        },
    };

    function ReplaceMarketModelForm(context) {
        this.context = context;
    }

    return ReplaceMarketModelForm;
}());

$(document).on('page:change', function () {
    'use strict';

    var replace = $(".replace_market_model");

    if (replace.length > 0) {
        new ReplaceMarketModelForm(replace).initialize();
    }
});

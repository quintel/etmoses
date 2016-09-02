var EdsnSwitch = (function () {
    'use strict';

    var EDSN_THRESHOLD = 30,
        validBaseLoads = /^(base_load|base_load_edsn)$/;

    function swapSelectBox() {
        var target       = $(this),
            type         = target.data('type'),
            profile      = target.data('profile'),
            unitSelector = target.find(".units input"),
            units        = parseInt(unitSelector.val(), 10),
            actual       = (units > EDSN_THRESHOLD ? "base_load_edsn" : "base_load"),
            options      = $(".hidden.profile select." + actual).find("option").clone(true, true),
            select       = target.find('.editable.profile select');

        select.html(options);

        if (type === actual) {
            select.val(profile);
        } else {
            select.trigger('change');
        }

        target.set('profile', parseInt(select.val(), 10));
        target.set('type', actual);

        unitSelector.off('change.units').on('change.units', swapSelectBox.bind(target));
    }

    return {
        cloneAndAppendProfileSelect: function (target) {
            var type = $(target).data('type');

            if (validBaseLoads.test(type)) {
                swapSelectBox.call(target);
            }
        }
    };
}());

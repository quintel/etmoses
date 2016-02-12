var EdsnSwitch = (function () {
    'use strict';

    var EDSN_THRESHOLD = 30,
        validBaseLoads = /^(base_load|base_load_edsn)$/;

    function swapSelectBox() {
        var self         = this,
            type         = $(this.target).data('type'),
            profile      = $(this.target).data('profile'),
            unitSelector = $(this.target).find(".units input"),
            units        = parseInt(unitSelector.val(), 10),
            actual       = (units > EDSN_THRESHOLD ? "base_load_edsn" : "base_load"),
            options      = $(".hidden.profile select." + actual).find("option").clone(true, true),
            select       = $(this.target).find('.editable.profile select');

        select.html(options);

        if(type === actual) {
            select.val(profile);
        } else {
            select.trigger('change');
        }

        $(this.target).set('profile', parseInt(select.val(), 10));
        $(this.target).set('type', actual);

        unitSelector.off('change.units').on('change.units', swapSelectBox.bind(self));
    }

    EdsnSwitch.prototype = {
        isEdsn: function () {
            return validBaseLoads.test($(this).data('type'));
        },

        cloneAndAppendProfileSelect: function () {
            swapSelectBox.call(this);
        }
    };

    function EdsnSwitch() {
        return;
    }

    return EdsnSwitch;
}());

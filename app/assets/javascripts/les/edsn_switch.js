var EdsnSwitch = (function () {
    'use strict';

    var EDSN_THRESHOLD = 30,
        validBaseLoads = /^(base_load|base_load_edsn)$/;

    function swapSelectBox() {
        var technology   = $(this.target).data('type'),
            self         = this,
            unitSelector = $(this.target).find(".units input"),
            units        = parseInt(unitSelector.val(), 10),
            actual       = (units > EDSN_THRESHOLD ? "base_load_edsn" : "base_load"),
            select       = $(".hidden.profile select." + actual).clone(true, true);

        $(this.target).find('.editable.profile select').replaceWith(select);
        $(this.target).find("option[value='" + technology + "']").attr('value', actual);

        unitSelector.off('change.units').on('change.units', swapSelectBox.bind(self));

        return select;
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

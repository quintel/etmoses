var Rounder = (function () {
    'use strict';

    function writeRaw() {
        this.data('raw', this.val());
    }

    function isValidInput(e) {
        return e.target !== e.currentTarget &&
            $(e.target).data('round') !== undefined;
    }

    function onInputFocus(e) {
        if (isValidInput(e)) {
            var target = $(e.target);

            target.val(target.data('raw'));
        }
    }

    function onInputChange(e) {
        if (isValidInput(e)) {
            writeRaw.call($(e.target));
        }

        e.stopPropagation();
    }

    function onInputBlur(e) {
        if (isValidInput(e)) {
            this.round.call($(e.target));
        }

        e.stopPropagation();
    }

    Rounder.prototype = {
        eachInput: function (method) {
            $(this.template).find("input[data-round]")
                .toArray().forEach(function (input) {
                    method.call($(input));
                });
        },

        initialize: function () {
            this.eachInput(writeRaw);
            this.eachInput(this.round);

            this.template.addEventListener('focus', onInputFocus, true);
            this.template.addEventListener('change', onInputChange, false);
            this.template.addEventListener('blur', onInputBlur.bind(this), true);
        },

        round: function () {
            var rounding,
                correction,
                rounded,
                value = parseFloat(this.val()),
                roundTo = this.data('round');

            if (!isNaN(value)) {
                rounding   = value + "e+" + roundTo;
                correction = "e-" + roundTo;
                rounded    = +(Math.round(rounding) + correction);

                this.val(rounded);
            }
        }

    };

    function Rounder(template) {
        this.template = template;
    }

    return Rounder;
}());

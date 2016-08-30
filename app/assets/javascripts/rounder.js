var Rounder = (function () {
    'use strict';

    function round() {
        var rounding,
            correction,
            rounded,
            value = parseFloat(this.input.val());

        if (!isNaN(value)) {
            rounding   = value + "e+" + this.roundTo,
            correction = "e-" + this.roundTo,
            rounded    = +(Math.round(rounding) + correction);

            this.input.val(rounded);
        }
    }

    function showRawValue() {
        var rawValue = this.input.data('raw');

        this.input.val(rawValue);
    }

    function writeRaw() {
        this.input.set('raw', this.input.val());
    }

    Rounder.prototype = {
        initialize: function () {
            writeRaw.call(this);
            round.call(this);

            this.input.off('focus.rounder')
                .on('focus.rounder', showRawValue.bind(this));

            this.input.off('change.rounder')
                .on('change.rounder', writeRaw.bind(this));

            this.input.off('blur.rounder')
                .on('blur.rounder', round.bind(this));
        }
    };

    function Rounder(input) {
        this.input   = $(input);
        this.roundTo = this.input.data('round');
    }

    return Rounder;
}());

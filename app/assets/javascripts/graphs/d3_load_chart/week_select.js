var WeekSelect = (function () {
    'use strict';

    WeekSelect.prototype = {
        initialize: function (currentWeek, callback) {
            this.select
                .removeClass('hidden')
                .val(currentWeek.toString())
                .off('change.callback')
                .on('change.callback', callback);
        },

        set: function (date) {
            this.select.val(date);
        },

        enable: function () {
            this.select.prop('disabled', false);
        },

        disable: function () {
            this.select.prop('disabled', true)
        }
    }

    function WeekSelect() {
        this.select = $('select.load-date');
    }

    return WeekSelect;
}());

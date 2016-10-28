/*global ETHelper*/

var ProfileSelectBox = (function () {
    'use strict';

    function defaultCloneAndAppend(triggerCallback) {
        var technology           = this.selectKey.val(),
            currentProfileSelect = $(this.target).find("select.profile"),
            newProfileSelect     = $(".hidden.profile select." + technology).clone(true, true),
            newProfileSelectVal  = newProfileSelect.find("option:first-child").val();

        newProfileSelect
            .val(newProfileSelectVal)
            .off('change')
            .on('change', this.callback);

        currentProfileSelect
            .replaceWith(newProfileSelect)
            .trigger('change');
    }

    ProfileSelectBox.prototype = {
        add: function (callback) {
            this.selectKey = $(this.target).find("select.key");
            this.callback  = callback;

            this.selectKey
                .off('change')
                .on('change', defaultCloneAndAppend.bind(this));
        }
    };

    function ProfileSelectBox(target) {
        this.target = target;
    }

    return ProfileSelectBox;
}());

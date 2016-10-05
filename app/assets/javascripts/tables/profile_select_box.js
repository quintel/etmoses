/*global ETHelper*/
var ProfileSelectBox = (function () {
    'use strict';

    function defaultCloneAndAppend(triggerCallback) {
        addProfileSelectBox.call(this);

        if (triggerCallback) {
            this.callback(this.target);
        }
    }

    function addProfileSelectBox() {
        var profile          = $(this.target).find("select.profile").val(),
            profileSelectBox = $(".hidden.profile select." + this.technology).clone(true, true);

        $(this.target).find(".editable.profile select")
            .replaceWith(profileSelectBox)
            .trigger('change');

        if (profile) {
            profileSelectBox.val(profile);
            profileSelectBox.off('change').on('change', this.callback);
        }
    }

    ProfileSelectBox.prototype = {
        add: function (callback) {
            var selectKey   = $(this.target).find("select.key");

            this.technology = selectKey.val(),
            this.callback   = callback;

            selectKey.off('change')
                     .on('change', defaultCloneAndAppend.bind(this, true));

            defaultCloneAndAppend.call(this, false);
        }
    };

    function ProfileSelectBox(target) {
        this.target = target;
    }

    return ProfileSelectBox;
}());

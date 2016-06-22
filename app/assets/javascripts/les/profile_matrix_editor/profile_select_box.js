/*global ETHelper*/
var ProfileSelectBox = (function () {
    'use strict';

    function defaultCloneAndAppend() {
        var technology       = $(this.target).find("select.key").val(),
            profile          = $(this.target).find("select.profile").val(),
            profileSelectBox = $(".hidden.profile select." + technology).clone(true, true);

        if (profile) {
            profileSelectBox.val(profile);
        }

        profileSelectBox.off('change').on('change', this.callback);

        this.callback(this.target);

        $(this.target).find(".editable.profile select")
            .replaceWith(profileSelectBox)
            .trigger('change');
    }

    ProfileSelectBox.prototype = {
        add: function (callback) {
            this.callback = callback || function () { return; };

            $(this.target).find("select.key").off('change')
                .on('change', defaultCloneAndAppend.bind(this));

            defaultCloneAndAppend.call(this);
        }
    };

    function ProfileSelectBox(target, callback) {
        this.target = target;
        this.callback = callback || function () { return; };
    }

    return ProfileSelectBox;
}());

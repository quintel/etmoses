/*global ETHelper*/
var ProfileSelectBox = (function () {
    'use strict';

    /* Callback for profile selector
     * Whenever somebody select's a different heat asset the data from that
     * select option will be parsed over the table row and the values set
     * in their respectable inputs and select boxes.
     */
    function updateRows(technology) {
        var technology = $(this.target).find("select.key"),
            techData   = $(technology).selectedOption().data();

        for (var key in techData) {
            $(this.target)
                .find(".editable." + key.underscorize())
                .find("input, select")
                .val(techData[key]);
        }
    }

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
            this.callback   = callback || updateRows.bind(this);

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

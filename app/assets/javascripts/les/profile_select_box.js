/*global EdsnSwitch,ETHelper*/
var ProfileSelectBox = (function () {
    'use strict';

    var edsnSwitch,
        defaultValues = {
            defaultCapacity: null,
            defaultDemand: null,
            defaultVolume: null
        };

    function updateSelectBox() {
        $(this).parent().next().find("select").val($(this).data('type'));
    }

    function getDefaults(value) {
        return $(this).selectedOption(value).data() || defaultValues;
    }

    function setCellDefault() {
        var inputField = $(this.techBox).find('.' + this.key + " input"),
            userInput  = parseFloat(inputField.val()),
            def        = (this.profileDefault || this.techDefault || '');

        $(this.techBox).set(this.key, userInput || def);
        inputField.val(userInput || def);
    }

    function updateTextCells(profileSelectBox) {
        var key,
            defaultValue,
            technologyDefaults = getDefaults.call($(".add-technology select"), $(this).data('type')),
            profileDefaults    = getDefaults.call(profileSelectBox, $(profileSelectBox).val());

        for (defaultValue in defaultValues) {
            key = defaultValue.replace(/default/, '').toLowerCase();

            setCellDefault.call({
                techBox: this,
                key: key,
                techDefault: technologyDefaults[defaultValue],
                profileDefault: profileDefaults[defaultValue]
            });
        }
    }

    function defaultCloneAndAppend() {
        var technology       = $(this.target).data("type"),
            profile          = $(this.target).data('profile'),
            profileSelectBox = $(".hidden.profile select." + technology).clone(true, true);

        if (profile) {
            profileSelectBox.val(profile);
        }

        $(this.target).find(".editable.profile select").replaceWith(profileSelectBox);

        updateTextCells.call(this.target, profileSelectBox);
    }

    function cloneAndAppendProfileSelect() {
        if (edsnSwitch.isEdsn.call($(this.target))) {
            updateTextCells.call(this.target,
                edsnSwitch.cloneAndAppendProfileSelect.call(this));
        } else {
            defaultCloneAndAppend.call(this);
        }
    }

    function addChangeListenerToProfileBox() {
        var self = this;

        $(this.target).find(".editable.profile select").off().on("change", function () {
            var technology = $(this).parents(".technology");

            technology.set('profile', $(this).val());
            technology.set('profile-key', $(this).selectedOption().text());

            updateTextCells.call(technology, this);
            self.callback.call(this);
        });
    }

    ProfileSelectBox.prototype = {
        add: function (callback) {
            this.callback = (callback || function () { return; });

            cloneAndAppendProfileSelect.call(this);
            addChangeListenerToProfileBox.call(this);
        },

        update: function () {
            updateSelectBox();
        }
    };

    function ProfileSelectBox(target) {
        this.target = target;
        edsnSwitch  = new EdsnSwitch();
    }

    return ProfileSelectBox;
}());

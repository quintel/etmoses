var ProfileSetter = (function () {
    'use strict';

    var profileSelect,
        currentOption,
        nextOption;

    function getNextOption() {
        var current = profileSelect.selectedOption(currentOption);

        if (current.next().length > 0) {
            return current.next();
        } else {
            return profileSelect.find("option").first();
        }
    }

    function selectProfile() {
        profileSelect = $(this).find("select.profile");
        nextOption    = getNextOption.call(profileSelect);
        currentOption = nextOption.attr('value');

        profileSelect.val(currentOption);
        $(this).set('profile', currentOption);
    }

    return {
        set: function () {
            currentOption = $(this.originTemplate).find("select.profile").val();

            this.templates.each(selectProfile);
        }
    };
}());

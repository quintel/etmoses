/*global EdsnSwitch,ETHelper*/
var ProfileSelectBox = (function () {
    'use strict';

    var etmDefaults, edsnSwitch,
        defaultValues = {
            defaultCapacity: null,
            defaultDemand: null,
            defaultVolume: null
        },
        attributes = {
            technical_lifetime: null,
            initial_investment: null,
            full_load_hours: null,
            om_costs_per_year: null,
            om_costs_per_full_load_hour: null,
            om_costs_for_ccs_per_full_load_hour: null
        };

    function updateSelectBox() {
        $(this).parent().next().find("select").val($(this).data('type'));
    }

    function getDefaults(value) {
        var selectedOption = $(this).find("option[value='" + value + "']");

        return selectedOption.data() || defaultValues;
    }

    function defaultsFromEtm(tech) {
        return etmDefaults[tech] ? etmDefaults[tech][0] : {};
    }

    function setCellDefault() {
        var inputField = $(this.techBox).find('.' + this.key + " input"),
            technology = $(this.techBox).data('type'),
            etmValue   = defaultsFromEtm(technology)[this.key],
            userInput  = parseFloat(inputField.val()),
            def        = (etmValue || this.profileDefault || this.techDefault || '');

        if (etmValue === userInput) {
            userInput = undefined;
        }

        $(this.techBox).attr('data-' + this.key, userInput || def);
        inputField.val(userInput || def);
    }

    function updateTextCells(profileSelectBox) {
        var key,
            defaultValue,
            technologyDefaults = getDefaults.call($(".row.add-technology select"), $(this).data('type')),
            profileDefaults    = getDefaults.call(profileSelectBox, $(profileSelectBox).val());

        for (defaultValue in defaultValues) {
            key = defaultValue.replace(/default/, '').toLowerCase();

            if (key === 'capacity') {
                key = 'electrical_capacity';
            }

            setCellDefault.call({
                techBox: this,
                key: key,
                techDefault: technologyDefaults[defaultValue],
                profileDefault: profileDefaults[defaultValue]
            });
        }
    }

    function defaultCloneAndAppend() {
        var technology = $(this.target).data("type"),
            profile = $(this.target).data('profile'),
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
        $(".editable.profile select").off().on("change", function () {
            updateTextCells(this, $(this).parents("tr"));
        });
    }

    function setEtmAttributes(data) {
        var key;
        for (key in attributes) {
            $(this.target).attr('data-' + key, data[key]);
            $(this.target).find("." + key + " input").val(data[key]);
        }

        cloneAndAppendProfileSelect.call(this);
        addChangeListenerToProfileBox();
        this.callback();
    }

    function shouldFetch() {
        return (/^(base_load|generic)/).test(this.type) || this.composite;
    }

    function fetchEtmAttributes() {
        if (shouldFetch.call($(this.target).data())) {
            setEtmAttributes.call(this, attributes);
        } else {
            $.ajax({
                type: "POST",
                url: $("#profiles-table").data("fetchUrl"),
                data: {
                    key: $(this.target).data('type')
                },
                success: setEtmAttributes.bind(this)
            });
        }
    }

    function setEtmDefaults() {
        var profile = JSON.parse($("#testing_ground_technology_profile").text()),
            technologies = [];

        Object.keys(profile).map(function (key) {
            technologies = technologies.concat(profile[key]);
        });

        return ETHelper.groupBy(technologies, 'type');
    }

    ProfileSelectBox.prototype = {
        add: function () {
            cloneAndAppendProfileSelect.call(this);
            addChangeListenerToProfileBox();
        },

        addNew: function (callback) {
            this.callback = callback || function () { return; };
            fetchEtmAttributes.call(this);
        },

        update: function () {
            updateSelectBox();
        }
    };

    function ProfileSelectBox(target) {
        this.target = target;
        etmDefaults = setEtmDefaults();
        edsnSwitch  = new EdsnSwitch();
    }

    return ProfileSelectBox;
}());

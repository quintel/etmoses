var ProfileSelectBoxes = (function () {
    'use strict';

    var etmDefaults, edsnSwitch,
        isChanged = false,
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

    function updateSelectBoxes() {
        $("select.name").each(function () {
            $(this).parent().next().find("select").val($(this).data('profile'));
        });
    }

    function getDefaults() {
        var selectedOption = $(this).find("option[value='" + $(this).val() + "']");

        return selectedOption.data() || defaultValues;
    }

    function defaultsFromEtm(tech) {
        return etmDefaults[tech] ? etmDefaults[tech][0] : {};
    }

    function setCellDefault() {
        var inputField = $(this.techBox).parents("tr").find('.' + this.key + " input"),
            technology = $(this.techBox).val(),
            etmValue   = defaultsFromEtm(technology)[this.key],
            userInput  = parseFloat(inputField.val());

        if (etmValue === userInput || isChanged) {
            userInput = undefined;
        }

        inputField.val(userInput || etmValue ||
            this.profileDefault || this.techDefault || '');
    }

    function updateTextCells(profileSelectbox) {
        var key,
            defaultValue,
            technologyDefaults = getDefaults.call(this),
            profileDefaults = getDefaults.call(profileSelectbox);

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
        var technology = $(this).val(),
            profileSelectbox = $(".hidden.profile select." + technology).clone(true, true);

        $(this).parents("tr").find(".units input").off("change");
        $(this).parent().next().html(profileSelectbox);

        updateTextCells.call(this, profileSelectbox);

        if (!isChanged) {
            profileSelectbox.val($(this).data('profile'));
        }
    }

    function cloneAndAppendProfileSelect() {
        if (edsnSwitch.isEdsn.call(this)) {
            updateTextCells.call(this,
                edsnSwitch.cloneAndAppendProfileSelect.call(this));
        } else {
            defaultCloneAndAppend.call(this);
        }
    }

    function addProfileSelectBoxes() {
        $("select.name").each(function () {
            cloneAndAppendProfileSelect.call(this);
        });
    }

    function setEtmAttributes(data) {
        for (var key in attributes) {
            $(this).parents("tr").find("." + key + " input").val(data[key]);
        }
    }

    function fetchEtmAttributes() {
        if (/^(base_load|generic)/.test($(this).val())) {
            setEtmAttributes.call(this, attributes);
            return false;
        };

        $.ajax({
            type: "POST",
            url: $("#profiles-table").data("fetchUrl"),
            data: {
                key: $(this).val()
            },
            success: setEtmAttributes.bind(this)
        });
    }


    function addChangeListenerToNameBox() {
        $("select.name").off("change").on("change", function () {
            isChanged = true;

            fetchEtmAttributes.call(this);
            cloneAndAppendProfileSelect.call(this);
        });
    }

    function addChangeListenerToProfileBox() {
        $("td.profile select").off().on("change", function () {
            updateTextCells(this, $(this).parents("tr"));
        });
    }

    function setEtmDefaults() {
        var profile = JSON.parse($("#testing_ground_technology_profile").text());
        var technologies = []

        Object.keys(profile).map(function (key) {
            technologies = technologies.concat(profile[key])
        });

        return ETHelper.groupBy(technologies, 'type');
    }

    ProfileSelectBoxes.prototype = {
        add: function() {
            addProfileSelectBoxes();
            addChangeListenerToNameBox();
            addChangeListenerToProfileBox();
        },

        update: function() {
            updateSelectBoxes();
        }
    };

    function ProfileSelectBoxes(thisEdsnSwitch) {
        etmDefaults = setEtmDefaults();
        edsnSwitch  = thisEdsnSwitch;
    }

    return ProfileSelectBoxes;
}());

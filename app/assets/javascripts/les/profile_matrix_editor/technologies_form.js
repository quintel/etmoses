/*global AddedTechnologiesValidator,AddTechnology,BatteryTemplateUpdater,
BufferSelectBox,Calculations,CompositeTemplateUpdater,ETHelper,RemoveTechnology,
TemplateUpdater,Technology*/

var TechnologiesForm = (function () {
    'use strict';

    // TODO: please remove
    function calculateInputCapacity() {
        $(this).find('.carrier_capacity input').val(
            Calculations.calculateInputCapacity.call($(this).data())
        );
    }

    function updateJSON() {
        var type   = $(this).data('type'),
            target = $(this).parents(".technology"),
            value  = $(this).val().replace(/[\'\" ]/g, '');

        $(this).val(value);
        target.set(type, value);

        if (type === 'capacity' || type === 'performance_coefficient') {
            calculateInputCapacity.call(target);
        }

        if ($(this).hasClass("slider")) {
            $(this).parents(".editable").find(".tick.value").text(value + "%");
        }

        window.currentTechnologiesForm.parseHarmonicaToJSON();
        window.currentTechnologiesForm.markAsEditing();
    }

    function updateTemplate(e) {
        var template = $(".technology_template .technology");

        this.currentSelectBox = $(e.target);

        new TemplateUpdater(template, this.currentSelectBox).update();
    }

    function addOnChangeListener() {
        var eventName;

        window.currentTechnologiesForm.parseHarmonicaToJSON();

        $(this).find("input, select").each(function () {
            eventName = $(this).hasClass("slider") ? 'slideStop' : 'change.json_update';

            $(this).off(eventName).on(eventName, updateJSON);
        });
    }

    function toggleAdvancedFeatures(e) {
        e.preventDefault();

        $(this).parents(".technology")
               .find(".editable.advanced")
               .toggleClass("hidden");
    }

    function addListeners() {
        $(".add-technology select").off().on("change", updateTemplate.bind(this));
        $(".add-technology button").off().on("click", AddTechnology.add);
        $(".add-technology select").first().trigger('change');
    }

    TechnologiesForm.prototype = {
        currentSelectBox: undefined,
        append: function () {
            $(".technologies .technology:not(.hidden)")
                .each(this.updateExistingTechnology);

            this.setProfiles();
            addListeners.call(this);

            this.parseHarmonicaToJSON();

            AddedTechnologiesValidator.validate();
        },

        /*
         * Loops over all the technology <div> tags in the html and extract all the data
         * attributes.
         * It than writes the data several hidden <div> tags
         */
        parseHarmonicaToJSON: function () {
            var tableProfile = $(".technologies .technology:not(.hidden)")
                .toArray()
                .map(function (target) {
                    return $(target).underscorizedData();
                }),
                groupedByNode = ETHelper.groupBy(tableProfile, 'node');

            $("#technology_distribution").text(JSON.stringify(tableProfile));
            $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
        },

        updateCounter: function (add) {
            var addition = (!!add),
                amount   = (addition ? 1 : -1),
                countDom = $(this).parents(".endpoint").find("h4 .count"),
                count    = parseInt(countDom.text().replace(/[\(\)]/g, ''), 10);

            countDom.text("(" + (count += amount) + ")");
        },

        updateExistingTechnology: function () {
            var edsnSwitch = new EdsnSwitch(this);

            new CompositeTemplateUpdater(this).update();
            new BatteryTemplateUpdater(this).update();
            new BufferSelectBox(this).add();

            if (edsnSwitch.isEdsn()) {
                edsnSwitch.cloneAndAppendProfileSelect();

                $(this).find(".profile select")
                    .off('change.edsn')
                    .on('change.edsn', edsnSwitch.cloneAndAppendProfileSelect);
            }

            $(this).find(".remove-row")
                .off("click").on("click", RemoveTechnology.remove);

            $(this).find(".show-advanced")
                .off("click").on("click", toggleAdvancedFeatures);

            addOnChangeListener.call(this);
        },

        markAsEditing: function () {
            $("ul.nav.nav-tabs li a[href=#technologies]").addClass("editing");
        },

        setProfiles: function () {
            $(".technologies .technology:visible").each(function () {
                var profileSelect = $(this).find(".profile select"),
                    profileId = $(this).data('profile');

                profileSelect.val(profileId);
            });
        }
    };

    function TechnologiesForm() {
        return;
    }

    return TechnologiesForm;
}());

$(document).on("page:change", function () {
    'use strict';

    if ($("#profiles-table").length > 0) {
        window.currentTechnologiesForm = new TechnologiesForm();
        window.currentTechnologiesForm.append();
    }
});

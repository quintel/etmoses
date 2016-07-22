/*globals BatteryTemplateUpdater,BufferSelectBox,Calculations,
CompositeTemplateUpdater,EdsnSwitch,RemoveTechnology,Splitter*/

var TechnologyTemplateFinalizer = (function () {
    'use strict';

    function addEdsnListener() {
        var edsnSwitch = new EdsnSwitch(this);

        if (edsnSwitch.isEdsn()) {
            edsnSwitch.cloneAndAppendProfileSelect();

            $(this).find(".profile select")
                .off('change.edsn')
                .on('change.edsn', edsnSwitch.cloneAndAppendProfileSelect);
        }
    }

    function toggleAdvancedFeatures(e) {
        e.preventDefault();

        $(this).parents(".technology")
               .find(".editable.advanced")
               .toggleClass("hidden");
    }

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

    function addOnChangeListener() {
        var eventName;

        window.currentTechnologiesForm.parseHarmonicaToJSON();

        $(this).find("input, select").each(function () {
            eventName = $(this).hasClass("slider") ? 'slideStop' : 'change.json_update';

            $(this).off(eventName).on(eventName, updateJSON);
        });
    }

    return {
        initialize: function () {
            new BufferSelectBox(this).add();

            addEdsnListener.call(this);
            addOnChangeListener.call(this);

            $(this).find(".remove-row")
                .off("click").on("click", RemoveTechnology.remove);

            $(this).find(".btn.split")
                .off("click").on("click", Splitter.split);

            $(this).find(".show-advanced")
                .off("click").on("click", toggleAdvancedFeatures);
        },

        update: function () {
            new CompositeTemplateUpdater(this).update();
            new BatteryTemplateUpdater(this).update();

            TechnologyTemplateFinalizer.initialize.call(this);
        }
    };
}());

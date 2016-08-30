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
        if (this.type === 'capacity' || this.type === 'performance_coefficient') {
            var inputCapacity = $(this.target).find('.carrier_capacity input'),
                inputData     = $(this.target).data(),
                calculated    = Calculations.calculateInputCapacity.call(inputData);

            inputCapacity.val(calculated).trigger('blur.rounder');
        }
    }

    function updateCompositeUnits() {
        if (this.type === 'units' && this.target.data('compositeValue')) {
            new CompositeTemplateUpdater(this.target).updateUnits();
        }
    }

    function setSliderTickValue() {
        if ($(this.input).hasClass("slider")) {
            $(this.input).parents(".editable")
                .find(".tick.value").text(this.value + "%");
        }
    }

    function updateJSONHooks() {
        return [
            calculateInputCapacity,
            updateCompositeUnits,
            setSliderTickValue
        ];
    }

    function updateJSON() {
        var type    = $(this).data('type'),
            target  = $(this).parents('.technology'),
            value   = $(this).rawValue().replace(/[\'\" ]/g, '');

        $(this).val(value);
        target.set(type, value);

        updateJSONHooks().forEach(function (hook) {
            hook.call({
                input:  this,
                target: target,
                value:  value,
                type:   type
            });
        }.bind(this));

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
            new CompositeTemplateUpdater(this).updateUnits();
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

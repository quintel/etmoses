/*globals BatteryTemplateUpdater,BufferSelectBox,Calculations,
CompositeTemplateUpdater,EdsnSwitch,RemoveTechnology,Splitter*/

var TechnologyTemplateFinalizer = (function () {
    'use strict';

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

            inputCapacity.val(calculated);
            new Rounder().round.call(inputCapacity);
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
        var obj     = $(this),
            type    = obj.data('type'),
            target  = obj.parents('.technology'),
            value   = obj.rawValue().replace(/[\'\" ]/g, '');

        obj.val(value);
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

    function updateEvent(e) {
        if (e.target !== e.currentTarget) {
            updateJSON.call(e.target);

            EdsnSwitch.cloneAndAppendProfileSelect(this);
        }

        e.stopPropagation();
    }

    function addOnChangeListener() {
        new Rounder(this).initialize();

        EdsnSwitch.cloneAndAppendProfileSelect(this);

        this.addEventListener('change', updateEvent, false);

        $(this).find(".slider[data-type]")
            .off('slideStop')
            .on('slideStop', updateJSON);
    }

    /* This has to be a DOMElement it can't be jQuery selection for that
     * will fail
     * */
    return {
        initialize: function () {
            var elem = $(this);

            new CompositeTemplateUpdater(this).updateUnits();
            new BufferSelectBox(this).add();

            addOnChangeListener.call(this);

            elem.find(".remove-row")
                .off("click").on("click", RemoveTechnology.remove);

            elem.find(".btn.split")
                .off("click").on("click", Splitter.split);

            elem.find(".show-advanced")
                .off("click").on("click", toggleAdvancedFeatures);
        },

        load: function () {
            var elem          = $(this),
                profileSelect = elem.find(".profile select"),
                profileId     = elem.data('profile');

            profileSelect.val(profileId);

            TechnologyTemplateFinalizer.initialize.call(this);
        },

        update: function () {
            new CompositeTemplateUpdater(this).update();
            new BatteryTemplateUpdater(this).update();

            TechnologyTemplateFinalizer.initialize.call(this);
        }
    };
}());

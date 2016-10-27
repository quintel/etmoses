/*globals BatteryTemplateUpdater,BufferSelectBox,Calculations,
CompositeTemplateUpdater,EdsnSwitch,RemoveTechnology,Rounder,
Splitter*/

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
            new CompositeTemplateUpdater(this.target[0]).updateUnits();
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
            value   = obj.rawValue();

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
        window.currentTechnologiesForm.tab.markAsEditing();
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

    function setProfile() {
        var profileSelect = this.find(".profile select"),
            profileId     = this.data('profile');

        profileSelect.val(profileId);
    }

    /* `this` has to be a DOMElement. It can't be jQuery selection because that
     * will fail
     * */
    return {
        initialize: function () {
            var elem = $(this);

            setProfile.call(elem);

            new CompositeTemplateUpdater(this).updateUnits();
            new BufferSelectBox(this).add();

            addOnChangeListener.call(this);

            elem.off("click.focusTemplate")
                .on("click.focusTemplate", window.currentTechnologiesForm.focusTemplate);

            elem.find(".remove-row")
                .off("click").on("click", RemoveTechnology.remove);

            elem.find(".btn.split")
                .off("click").on("click", Splitter.split);

            elem.find(".show-advanced")
                .off("click").on("click", toggleAdvancedFeatures);
        },

        update: function () {
            new CompositeTemplateUpdater(this).update();
            new BatteryTemplateUpdater(this).update();

            TechnologyTemplateFinalizer.initialize.call(this);
        }
    };
}());

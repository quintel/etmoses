/*globals Ajax,BatteryTemplateUpdater,BufferOptions,BufferSelectBox,
Calculations, CompositeTemplateUpdater,FormHelper,ProfileSelectBox,
TemplateSettings, btoa*/
var TemplateUpdater = (function () {
    'use strict';

    /*
     * This prototype updates the existing hidden template depending on the
     * chosen technology.
     */
    function addCount(value, joinCharacter) {
        if (this.data.composite) {
            var bufferIndex = (FormHelper.bufferIndexes[this.data.type] || 0) + 1;
            value = value + joinCharacter + bufferIndex;
        }

        return value;
    }

    function setInputs() {
        var key, input;
        for (key in this.data) {
            input = this.template.find("." + key.underscorize() + " input")
            input.val(this.data[key]);

            if (!(input.attr("disabled") === "disabled")) {
                this.template.set(key, this.data[key]);
            }
        }

        return this.template;
    }

    function updatePositionOfTechnology() {
        var uniqueIdentifier = btoa(Date.now()),
            positionRelativeToBuffer = $(this.template).data('positionRelativeToBuffer');

        this.template.find("input[type=radio]").attr("name", function () {
            return $(this).attr("name")
                       .replace(/[A-Za-z0-9=]+\_{2}$/, uniqueIdentifier + '__');
        });

        if (positionRelativeToBuffer) {
            this.template
                .find("input[type=radio][value=" + positionRelativeToBuffer + "]")
                .prop('checked', true);
        }
    }

    function updateDefaults() {
        this.template.find("strong").text(this.data.name);
        this.template.attr("class", this.data.type + ' technology');
        updatePositionOfTechnology.call(this);

        return this.template;
    }

    function parseTemplate() {
        // Reset the template inputs to nothing
        this.template.find("input").val('');

        // Continue on parsing
        this.template = setInputs.call(this);
        this.template = updateDefaults.call(this);
    }

    function initializeTemplate() {
        this.template = new CompositeTemplateUpdater(this).update();
        this.template = new BatteryTemplateUpdater(this).update();

        new ProfileSelectBox(this.template).add();
    }

    /*
     * Find the details of 'underscorize()' in extensions.js
     */
    function setEtmAttributes(etmData) {
        var index, key;

        for (index in TemplateSettings.etmKeys) {
            key = TemplateSettings.etmKeys[index];

            this.data[key] = etmData[key.underscorize()];
        }

        parseTemplate.call(this);
        $(this.technologySelectBox).parent().find("button").removeClass("disabled");
    }

    function shouldFetch() {
        return TemplateSettings.ignoredTechs.indexOf(this.data.type) === -1;
    }

    function fetchEtmAttributes() {
        if (shouldFetch.call(this)) {
            var url = $("#profiles-table").data("fetchUrl");

            $(this.technologySelectBox).parent().find("button").addClass("disabled");

            Ajax.json(url, { key: this.data.type }, setEtmAttributes.bind(this));
        } else {
            setEtmAttributes.call(this, {});
        }
    }

    function bufferFilter(data) {
        var techData = $(this).data();

        return techData.composite && techData.includes.indexOf(data.type) > -1;
    }

    function buildCompSelector(comp) {
        var id;

        if (comp.length > 0) {
            return ('.' + comp.attr("class").replace(/\s/g, '.') +
                "[data-composite-value='" + comp.data('compositeValue') + "']");
        } else {
            id = $(this.technologySelectBox)
                    .parents(".panel")
                    .find(".panel-collapse")
                    .attr("id");

            return ('#' + id + ' .technologies .technology:first-child');
        }
    }

    function findNearestCompositValue() {
        var self = this,
            comp = $(this.technologySelectBox).parents(".endpoint").find(".technologies .technology").filter(function () {
                return bufferFilter.call(this, self.data);
            }).last();

        this.data.append = buildCompSelector.call(this, comp);

        return comp.length > 0 ? comp.data('compositeValue') : '';
    }

    function setProfileValues() {
        if (this.data.buffer !== "") {
            this.data.profile = '';
            this.data.profileKey = '';
        } else {
            var profileSelect = $(".data .hidden.profile select." + this.data.type);

            this.data.profile = profileSelect.val();
            this.data.profileKey = profileSelect.selectedOption().text();
        }
    }

    function setCompositeValues() {
        if (this.data.composite) {
            this.data.compositeValue = addCount.call(this, this.data.type, '_');
            this.data.includes       = FormHelper.includesFor(this.data.type);
        } else {
            this.data.compositeValue = '';
            this.data.includes = [];
        }
    }

    function setInitialDataFromSelectBox() {
        var option                         = $(this.technologySelectBox).selectedOption();

        this.data.node                     = $(this.data.append).data('node');
        this.data.type                     = $(this.technologySelectBox).val();
        this.data.composite                = option.data('composite');
        this.data.includes                 = option.data('includes');
        this.data.positionRelativeToBuffer = option.data('positionRelativeToBuffer');
        this.data.name                     = addCount.call(this, option.text(), ' #');
        this.data.buffer                   = findNearestCompositValue.call(this);
        this.data.carrierCapacity          = Calculations.calculateInputCapacity.call(this.data);
        this.data.units                    = 1;

        setCompositeValues.call(this);
        setProfileValues.call(this);
    }

    TemplateUpdater.prototype = {
        data: {},
        update: function () {
            setInitialDataFromSelectBox.call(this);
            fetchEtmAttributes.call(this);
        },

        updateExisting: function () {
            updatePositionOfTechnology.call(this);
        },

        addToRow: function () {
            setInitialDataFromSelectBox.call(this);
            parseTemplate.call(this);
            initializeTemplate.call(this);
        }
    };

    function TemplateUpdater(template, technologySelectBox) {
        this.template = template;
        this.technologySelectBox = technologySelectBox;
    }

    return TemplateUpdater;
}());

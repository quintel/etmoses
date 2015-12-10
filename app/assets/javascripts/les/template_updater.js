/*globals Ajax,BufferOptions,BufferSelectBox,CompositeTemplateUpdater,FormHelper,
 ProfileSelectBox*/
var TemplateUpdater = (function () {
    'use strict';

    /*
     * This prototype updates the existing template depending on the
     * chosen technology.
     */

    /*
     * ignoredTechs
     *    Technologies that don't exist in et-engine
     *
     * etmKeys:
     *    Attributes that are to be used from et-engine
     *    The attributes are camelcased due to HTML5 DOM API
     */
    var ignoredTechs = [
            'base_load', 'base_load_edsn', 'base_load_buildings', 'generic',
            'buffer_space_heating', 'buffer_water_heating'
        ],
        etmKeys = [
            'technicalLifetime', 'initialInvestment', 'fullLoadHours',
            'omCostsPerYear', 'omCostsPerFullLoadHour', 'omCostsForCcsPerFullLoadHour'
        ];

    function addCount(value, joinCharacter) {
        if (this.data.composite) {
            var bufferIndex = (FormHelper.bufferIndexes[this.data.type] || 0) + 1;
            value = value + joinCharacter + bufferIndex;
        }

        return value;
    }

    function setInputs() {
        var key;
        for (key in this.data) {
            this.template.set(key, this.data[key]);
            this.template.find("." + key.underscorize() + " input").val(this.data[key]);
        }

        return this.template;
    }

    function parseTemplate() {
        this.template = setInputs.call(this);
        this.template.find("strong").text(this.data.name);
        this.template.attr("class", this.data.type + ' technology');
        this.template.find("input[type=radio]").attr("name", function () {
            return $(this).attr("name").replace(/\_{2}/, '_' + $(".technology").length);
        });
        this.template.find("input[type=radio][value=" + this.data.positionRelativeToBuffer + "]")
            .prop('checked', true);

        this.template = new CompositeTemplateUpdater(this).update();

        new ProfileSelectBox(this.template).add();
    }

    /*
     * Find the details of 'underscorize()' in extensions.js
     */
    function setEtmAttributes(etmData) {
        var index, key;

        for (index in etmKeys) {
            key = etmKeys[index];

            this.data[key] = etmData[key.underscorize()];
        }

        parseTemplate.call(this);
        $(this.technologySelectBox).parent().find("button").removeClass("disabled");
    }

    function shouldFetch() {
        return ignoredTechs.indexOf(this.data.type) === -1;
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
        if (comp.length > 0) {
            var compClass = '.' + comp.attr("class").replace(/\s/g, '.');

            return compClass +
                "[data-composite-value='" + comp.data('compositeValue') + "']";
        } else {
            var id = $(this.technologySelectBox).parents(".panel-collapse").attr("id");

            return '#' + id + ' .technologies .technology:last-child';
        }
    }

    function findNearestCompositValue() {
        var self = this,
            comp = $(this.technologySelectBox).parents(".panel-body").find(".technologies .technology").filter(function () {
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

        this.data.type                     = $(this.technologySelectBox).val();
        this.data.composite                = option.data('composite');
        this.data.includes                 = option.data('includes');
        this.data.positionRelativeToBuffer = option.data('positionRelativeToBuffer');
        this.data.name                     = addCount.call(this, option.text(), ' #');
        this.data.buffer                   = findNearestCompositValue.call(this);
        this.data.node                     = $(this.data.append).data('node');
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

        increaseCompositeValue: function () {
            setInitialDataFromSelectBox.call(this);
            parseTemplate.call(this);
        }
    };

    function TemplateUpdater(template, technologySelectBox) {
        this.template = template;
        this.technologySelectBox = technologySelectBox;
    }

    return TemplateUpdater;
}());

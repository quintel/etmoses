/*global ETHelper,ProfileSelectBox,TechnologyTemplate*/
var TechnologiesForm = (function () {
    'use strict';

    function parseHarmonicaToJSON() {
        var tableProfile = $(".technologies .technology").toArray().map(function (target) {
                return $(target).underscorizedData();
            }),
            groupedByNode = ETHelper.groupBy(tableProfile, 'node');

        $("#technology_distribution").text(JSON.stringify(tableProfile));
        $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
    }

    function updateJSON() {
        var type   = $(this).data('type'),
            target = $(this).parents(".technology"),
            value  = $(this).val();

        target.attr('data-' + type, value).data(type, value);

        parseHarmonicaToJSON();
    }

    function addProfileSelectBox() {
        new ProfileSelectBox(this).add();
    }

    function removeBufferOption() {
        if (this.composite) {
            $(this.target).find(".buffer_template select").selectedOption(this.value).remove();
        }
    }

    function addTechnologyTemplate() {
        new TechnologyTemplate(this).addTo(function () {
            parseHarmonicaToJSON();
            $(this).find("input, select").on('change', updateJSON);
        });
    }

    function addNewTechnologyRow() {
        var technologySelect = $(this).parents(".input-group").find("select.name"),
            technologyVal    = technologySelect.val(),
            technologyOption = technologySelect.selectedOption(),
            target           = $(this).parents(".panel-body").find(".technologies");

        addTechnologyTemplate.call({ target:    target,
                                     value:     technologyVal,
                                     title:     technologyOption.text(),
                                     composite: technologyOption.data('composite'),
                                     includes:  technologyOption.data('includes') });
    }

    function toggleAdvancedFeatures() {
        $(this).parents(".technology").find(".editable.advanced").toggleClass("hidden");
    }

    function removeable() {
        var canBeRemoved = true,
            technology = $(this).parents(".technology"),
            target = $(this).parents(".technologies");

        target.find(".technology .buffer select:visible").each(function () {
            if ($(this).val() === technology.data('value')) {
                canBeRemoved = false;
                return false;
            }
        });

        return canBeRemoved;
    }

    function removeTechnologyRow() {
        var technology = $(this).parents(".technology");

        if (removeable.call(this)) {
            removeBufferOption.call({ value:     technology.data().type,
                                      composite: technology.data().composite });

            technology.remove();
        } else {
            alert("There are technologies that use this buffer, remove these first before removing this buffer");
        }

        parseHarmonicaToJSON();
    }

    function addListenersToNewTechnology() {
        $(".technologies .technology").each(addProfileSelectBox);
        $(".technologies .technology input, .technologies .technology select").on('change', updateJSON);
        $(".add-technology button").on("click", addNewTechnologyRow);
        $(".technology .remove-row").on("click", removeTechnologyRow);
        $(".technology .show-advanced").on("click", toggleAdvancedFeatures);
    }

    TechnologiesForm.prototype = {
        append: function () {
            addListenersToNewTechnology.call(this);
            parseHarmonicaToJSON.call(this);
        }
    };

    function TechnologiesForm(selector) {
        this.selector    = selector;
        this.bufferCount = 0;
    }

    return TechnologiesForm;
}());

$(document).on("page:change", function () {
    'use strict';

    if ($("#profiles-table").length > 0) {
        window.currentTechnologiesForm = new TechnologiesForm("#profiles-table");
        window.currentTechnologiesForm.append();
    }
});

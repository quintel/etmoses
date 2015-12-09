/*global ETHelper,ProfileSelectBox,TechnologyTemplate*/
var TechnologiesForm = (function () {
    'use strict';

    /*
     * Loops over all the technology <div> tags in the html and extract all the data
     * attributes.
     * It than writes the data several hidden <div> tags
     */
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

        target.set(type, value);

        parseHarmonicaToJSON();
    }

    function addProfileSelectBox() {
        new ProfileSelectBox(this).add();
    }

    function addTechnologyTemplate() {
        new TechnologyTemplate(this).addTo(function () {
            parseHarmonicaToJSON();
            $(this).find("input, select").off('change.json_update')
                .on('change.json_update', updateJSON);
        });
    }

    function addNewTechnologyRow(e) {
        e.preventDefault();

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

    function toggleAdvancedFeatures(e) {
        e.preventDefault();

        $(this).parents(".technology").find(".editable.advanced").toggleClass("hidden");
    }

    /*
     * Checks if a technology can be removed from the table.
     * For instance if you want to remove a buffer from the table and it still has
     * technologies attached to it, it should alert the user that that is not possible.
     */
    function removeable() {
        var canBeRemoved = true,
            technology = $(this).parents(".technology"),
            target = $(this).parents(".technologies");

        target.find(".technology .buffer select:visible").each(function () {
            if ($(this).val() === technology.data('compositeValue')) {
                canBeRemoved = false;
                return false;
            }
        });

        return canBeRemoved;
    }

    function removeBufferOption() {
        if (this.composite) {
            $(".buffer_template select, .technology .buffer select")
                .selectedOption(this.compositeValue).remove();
        }
    }

    function removeTechnologyRow(e) {
        e.preventDefault();

        var technology = $(this).parents(".technology");

        if (removeable.call(this)) {
            removeBufferOption.call(technology.data());

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

            if (this.editing) {
                this.updateProfiles();
            }
        },

        updateProfiles: function () {
            $(".technologies .technology").each(function () {
                var techObject    = $(this).underscorizedData();

                techObject.target = $(this).parent();
                new TechnologyTemplate(techObject).update(this);
            });

            $(".technology").each(function () {
                $(this).find(".buffer select").val($(this).data('buffer'));
            });
        }
    };

    function TechnologiesForm(selector) {
        this.selector    = selector;
        this.editing     = $(selector).parents("form").hasClass("edit_testing_ground");
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

/*global ETHelper,TemplateUpdater,Technology*/
var TechnologiesForm = (function () {
    'use strict';

    var template = null;

    /*
     * Loops over all the technology <div> tags in the html and extract all the data
     * attributes.
     * It than writes the data several hidden <div> tags
     */
    function parseHarmonicaToJSON() {
        var tableProfile = $(".technologies .technology:not(.hidden)").toArray().map(function (target) {
                return $(target).underscorizedData();
            }),
            groupedByNode = ETHelper.groupBy(tableProfile, 'node');

        $("#technology_distribution").text(JSON.stringify(tableProfile));
        $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
    }

    function markAsEditing() {
      $("ul.nav.nav-tabs li a[href=#technologies]").addClass("editing");
    }

    function updateJSON() {
        var type   = $(this).data('type'),
            target = $(this).parents(".technology"),
            value  = $(this).val().replace(/[\'\" ]/g, '');

        $(this).val(value);
        target.set(type, value);

        parseHarmonicaToJSON();
        markAsEditing();
    }

    function updateTemplate() {
        new TemplateUpdater(template, this).update();
    }

    function addOnChangeListener() {
        parseHarmonicaToJSON();

        $(this).find("input, select")
            .off('change.json_update')
            .on('change.json_update', updateJSON);
    }

    function addNewTechnologyRow(e) {
        e.preventDefault();

        var newTemplate = template.clone(true, true),
            selectTechnology = $(this).parents(".add-technology").find("select");

        new TemplateUpdater(newTemplate, selectTechnology).increaseCompositeValue();
        new Technology(newTemplate).add(this);

        AddedTechnologiesValidator.validate();

        addOnChangeListener.call(newTemplate);
        markAsEditing();
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

            AddedTechnologiesValidator.validate();
        } else {
            alert("There are technologies that use this buffer, remove these first before removing this buffer");
        }

        parseHarmonicaToJSON();
        markAsEditing();
    }

    function addListenersToNewTechnology() {
        $(".add-technology select").off().on("change", updateTemplate);
        $(".add-technology button").on("click", addNewTechnologyRow);
        $(".technology .remove-row").on("click", removeTechnologyRow);
        $(".technology .show-advanced").on("click", toggleAdvancedFeatures);

        $(".add-technology select").first().trigger('change');
    }

    TechnologiesForm.prototype = {
        append: function () {
            $(".technologies .technology:not(.hidden)").each(function () {
                new Technology(this).update();

                addOnChangeListener.call(this);
            });

            addListenersToNewTechnology.call(this);
            parseHarmonicaToJSON.call(this);

            AddedTechnologiesValidator.validate();
        }
    };

    function TechnologiesForm() {
        template = $(".technology_template .technology");
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

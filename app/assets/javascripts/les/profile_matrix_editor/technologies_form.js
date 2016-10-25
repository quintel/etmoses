/*global AddedTechnologiesValidator,AddTechnology,ETHelper,MatrixEditorJSONParser,
TemplateUpdater,Technology,TechnologyTemplateFinalizer*/

var TechnologiesForm = (function () {
    'use strict';

    function updateTemplate(e) {
        var template = $(".technology_template .technology");

        new TemplateUpdater(template, e.target).update();
    }

    function addListeners() {
        $(".add-technology select")
            .off('change')
            .on("change", updateTemplate.bind(this));

        $(".add-technology button")
            .off('click')
            .on("click", AddTechnology.add);
    }

    TechnologiesForm.prototype = {
        append: function () {
            $(".technologies .technology:not(.hidden)")
                .each(TechnologyTemplateFinalizer.initialize);

            addListeners.call(this);

            this.parseHarmonicaToJSON();

            this.form.on('change', function () {
                this.tab.markAsEditing();
            }.bind(this));

            AddedTechnologiesValidator.validate();
        },

        /*
         * Loops over all the technology <div> tags in the html and extract all the data
         * attributes.
         * It than writes the data several hidden <div> tags
         */
        parseHarmonicaToJSON: function () {
            this.jsonParser.parse();
        },

        updateCounter: function (add) {
            var addition = (!!add),
                amount   = (addition ? 1 : -1),
                countDom = $(this).parents(".endpoint").find("h4 .count"),
                count    = parseInt(countDom.text().replace(/[\(\)]/g, ''), 10);

            countDom.text("(" + (count += amount) + ")");
        },

        focusTemplate: function () {
            $(".technologies .technology").removeClass("focus");
            $(this).addClass("focus");
        }
    };

    function TechnologiesForm(profilesTable) {
        this.form       = profilesTable.parents("form");
        this.jsonParser = new MatrixEditorJSONParser();
        this.tab        = new Tab("#technologies");
    }

    return TechnologiesForm;
}());

$(document).on("page:change", function () {
    'use strict';

    var profilesTable = $("#profiles-table");

    if (profilesTable.length > 0) {
        window.currentTechnologiesForm = new TechnologiesForm(profilesTable);
        window.currentTechnologiesForm.append();
    }
});

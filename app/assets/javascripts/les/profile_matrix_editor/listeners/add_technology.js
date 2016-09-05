/*globals AddedTechnologiesValidator,Bump,ScopeForTemplate,TemplateUpdater,
TechnologyTemplateFinalizer*/

var AddTechnology = (function () {
    'use strict';

    function finalize() {
        AddedTechnologiesValidator.validate();

        window.currentTechnologiesForm.markAsEditing();
        window.currentTechnologiesForm.updateCounter.call(this.context, true);

        TechnologyTemplateFinalizer.update.call(this.newTemplate[0]);

        window.currentTechnologiesForm.parseHarmonicaToJSON();
    }

    AddTechnology.prototype = {
        add: function () {
            this.newTemplate.set('buffer', $(this.appendScope).data('compositeValue'));
            this.newTemplate.set('node',   $(this.appendScope).data('node'));

            Bump.call(this.newTemplate);

            $(this.context).parents(".panel")
                .find(this.appendScope).after(this.newTemplate);

            finalize.call(this);
        }
    };

    function AddTechnology(context) {
        this.context            = context;
        this.newTemplate        = $(".technology_template .technology").clone(true, true);
        this.technologySelector = $(context).parents(".add-technology").find("select");
        this.appendScope        = new ScopeForTemplate(this.technologySelector).getScope();
    }

    return {
        add: function (e) {
            e.preventDefault();

            new AddTechnology(this).add();
        }
    };
}());

/*globals AddedTechnologiesValidator,Bump,ScopeForTemplate,TemplateUpdater,
TechnologyTemplateFinalizer*/

var AddTechnology = (function () {
    'use strict';

    function finalize() {
        var animOffset;

        AddedTechnologiesValidator.validate();

        window.currentTechnologiesForm.tab.markAsEditing();
        window.currentTechnologiesForm.updateCounter.call(this.context, true);

        TechnologyTemplateFinalizer.update.call(this.newTemplate[0]);

        if (this.newTemplate.hasClass("buffer-child")) {
            animOffset = ($(window).height() / 2) -
                (this.newTemplate.outerHeight() / 2);

            $.scrollTo(this.newTemplate, 500, { offset: { top: -animOffset } });
        }

        window.currentTechnologiesForm.focusTemplate.call(this.newTemplate);
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

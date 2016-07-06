/*globals AddedTechnologiesValidator,TemplateUpdater*/

var AddTechnology = (function () {
    'use strict';

    return {
        add: function (e) {
            e.preventDefault();

            var newTemplate      = $(".technology_template .technology").clone(true, true),
                selectTechnology = $(this).parents(".add-technology").find("select"),
                template         = new TemplateUpdater(newTemplate, selectTechnology),
                appendScope      = template.getAppendScope();

            template.bump();
            newTemplate.set('node', $(appendScope).data('node'));

            $(this).parents(".panel").find(appendScope).after(newTemplate);

            AddedTechnologiesValidator.validate();

            window.currentTechnologiesForm.markAsEditing();
            window.currentTechnologiesForm.updateCounter.call(this, true);
            window.currentTechnologiesForm.updateExistingTechnology.call(newTemplate);
        }
    };
}());

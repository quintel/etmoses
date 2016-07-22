/*globals AddedTechnologiesValidator,Bump,ProfileSetter,
TechnologyTemplateFinalizer*/

var Splitter = (function () {
    'use strict';

    function finalize() {
        AddedTechnologiesValidator.validate();

        window.currentTechnologiesForm.markAsEditing();
        window.currentTechnologiesForm.updateCounter.call(this, true);

        if (!this.composite) {
            TechnologyTemplateFinalizer.update.call(this.originTemplate);
        }

        this.templates.each(function () {
            TechnologyTemplateFinalizer.update.call(this);
        });
    }

    function setUnits() {
        var division    = this.clones + 1,
            originUnits = Math.floor(this.units / division),
            remainder   = this.units % division;

        this.originTemplate.find('.units input').val(originUnits + remainder);
        this.originTemplate.set('units', originUnits + remainder);

        this.templates.find('.units input').val(originUnits);
        this.templates.set('units', originUnits);
    }

    function cloneTemplate(originTemplate) {
        var i        = 0,
            buffer   = originTemplate.data('compositeValue') || 'none',
            children = $(".technology.buffer-child[data-buffer=" + buffer + "]"),
            template;

        this.appendScope = children.length > 0 ? children.last() : originTemplate;

        for (i; i < this.clones; i += 1) {
            template = originTemplate.clone(true, true);

            this.templates = this.templates.add(template);

            if (children.length > 0) {
                children.each(function (i, child) {
                    cloneTemplate.call(this, $(child));
                }.bind(this));
            }

            Bump.call(template);
        }
    }

    Splitter.prototype = {
        split: function () {
            // If the amount of units to split up in is smaller than 2.
            // Stop the code progression.
            if (this.units < 2) { return false; }

            cloneTemplate.call(this, this.originTemplate);

            $(this.appendScope).after(this.templates);
            setUnits.call(this);
            finalize.call(this);
        }
    };

    /* Takes a context (that off the split button).
     * And an amount of 'clones'.
     *
     * This prototype duplicates templates by the amount of clones and diverts
     * the original amount of units accross those templates.
     */
    function Splitter(context, clones) {
        this.originTemplate = $(context).parents(".technology");
        this.clones         = clones;
        this.templates      = $();
        this.units          = this.originTemplate.data('units');
        this.composite      = this.originTemplate.data('composite');
    }

    return {
        split: function (e) {
            e.preventDefault();

            new Splitter(this, 1).split();
        }
    };
}());

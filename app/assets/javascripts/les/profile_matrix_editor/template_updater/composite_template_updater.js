var CompositeTemplateUpdater = (function () {
    'use strict';

    function compositeFilter(d, e) {
        var techData = $(e).data();

        return techData.composite && techData.type === this.type;
    }

    function getNewIndex() {
        var compositeIndex = $(".technologies .technology")
            .filter(compositeFilter.bind(this))
            .map(function () {
                return $(this).data('compositeIndex') || 0;
            });

        return Math.max.apply(Math, compositeIndex) + 1;
    }

    function setName(index) {
        var nameBox     = this.template.find("strong"),
            currentName = $.trim(nameBox.text()).replace(/\s+\#[0-9]+$/, ''),
            newName     = currentName + " #" + index;

        this.template.set('name', newName);

        nameBox.text(newName);
    }

    CompositeTemplateUpdater.prototype = {
        updateUnits: function () {
            var units;

            if (this.composite) {
                units = this.units;
                this.children.each(function () {
                    $(this).set('units', units);
                    $(this).find(".editable.units.text input").val(units);
                });
            }
        },

        update: function () {
            var buffer,
                compositeValue,
                index;

            if (this.isChild) {
                buffer = this.template.prev();

                this.template.set('units', buffer.data('units'));
            }

            if (this.composite) {
                index          = getNewIndex.call(this);
                compositeValue = this.type + "_" + index;

                this.template.set('composite_index', index);
                this.template.set('composite_value', compositeValue);

                this.children.set('buffer', compositeValue);

                setName.call(this, index);
            }

            return this.template;
        }
    };

    function CompositeTemplateUpdater(template) {
        this.template  = $(template);
        this.type      = template.getAttribute('data-type');
        this.units     = template.getAttribute('data-units');
        this.composite = template.getAttribute('data-composite') === 'true';
        this.isChild   = template.getAttribute('data-buffer');
        this.children  = this.template.nextUntil(":not(.buffer-child)");
    }

    return CompositeTemplateUpdater;
}());

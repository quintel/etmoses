var CompositeTemplateUpdater = (function () {
    'use strict';

    function compositeFilter(d, e) {
        var techData = $(e).data();

        return techData.composite && techData.type === this.data.type;
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
        update: function () {
            if (this.data.composite) {
                var index          = getNewIndex.call(this),
                    compositeValue = this.data.type + "_" + index,
                    children       = this.template.nextUntil(":not(.buffer-child)");

                this.template.set('composite_index', index);
                this.template.set('composite_value', compositeValue);

                children.set('buffer', compositeValue)
                children.set('units',  this.data.units);

                setName.call(this, index);
            }

            return this.template;
        }
    };

    function CompositeTemplateUpdater(template) {
        this.template = $(template);
        this.data     = $(template).data();
    }

    return CompositeTemplateUpdater;
}());

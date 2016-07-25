var CompositeTemplateUpdater = (function () {
    'use strict';

    function compositeFilter(d, e) {
        var techData = $(e).data(),
            key = $(this.technologySelectBox).val();

        return techData.composite && techData.type === key;
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
        var nameBox = this.template.find("strong"),
            currentName = nameBox.text(),
            newName = currentName + " #" + index;

        this.template.set('name', newName);

        nameBox.text(newName);
    }

    CompositeTemplateUpdater.prototype = {
        update: function () {
            if (this.data.composite && !this.data.compositeIndex) {

                var index = getNewIndex.call(this);

                this.template.set('composite_index', index);
                this.template.set('composite_value', this.data.type + "_" + index);

                setName.call(this, index);
            }

            return this.template;
        }
    };

    function CompositeTemplateUpdater(template) {
        this.template            = $(template);
        this.data                = $(template).data();
        this.technologySelectBox = window.currentTechnologiesForm.currentSelectBox;
    }

    return CompositeTemplateUpdater;
}());

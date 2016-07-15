var ScopeForTemplate = (function () {
    'use strict';

    function bufferFilter(d, e) {
        var techData = $(e).data(),
            key = $(this.technologySelectBox).val();

        return techData.composite && techData.includes.indexOf(key) > -1;
    }

    function buildCompSelector(comp) {
        var id;

        if (comp.length > 0) {
            return ('.' + comp.attr("class").replace(/\s/g, '.') +
                "[data-composite-value='" + comp.data('compositeValue') + "']");
        } else {
            id = this.scope.find(".panel-collapse").attr("id");

            return ('#' + id + ' .technologies .technology:first-child');
        }
    }

    function getTechnologies() {
        return this.scope.find(".technologies .technology");
    }

    ScopeForTemplate.prototype = {
        getScope: function () {
            var lastComposite = getTechnologies.call(this)
                    .filter(bufferFilter.bind(this))
                    .first();

            return buildCompSelector.call(this, lastComposite);
        }
    };

    function ScopeForTemplate(technologySelectBox) {
        this.technologySelectBox = technologySelectBox;
        this.scope               = $(this.technologySelectBox).parents('.panel.endpoint');
    }

    return ScopeForTemplate;
}());

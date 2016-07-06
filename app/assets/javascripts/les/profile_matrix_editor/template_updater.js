/*globals Ajax,BufferOptions,BufferSelectBox,Calculations,FormHelper,
TemplateSettings, btoa*/

var TemplateUpdater = (function () {
    'use strict';

    function updateTechnologyTemplate() {
        var key = $(this.technologySelectBox).val(),
            url = $("#profiles-table").data("renderTemplateUrl");

        this.scope.find(".add-technology button").addClass("disabled");

        this.getAppendScope();

        $.ajax({
            url: url,
            type: "POST",
            dataType: 'script',
            data: { key: key, buffer: this.template.data('buffer') }
        });
    }

    function bufferFilter(d, e) {
        var techData = $(e).data(),
            key = $(this.technologySelectBox).val();

        return techData.composite && techData.includes.indexOf(key) > -1;
    }

    function buildCompSelector(comp) {
        var id;

        if (comp.length > 0) {
            this.template.set('buffer', comp.data('compositeValue'));

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

    TemplateUpdater.prototype = {
        update: function () {
            this.template.set('buffer', '');

            updateTechnologyTemplate.call(this);
        },

        bump: function () {
            var randId = "T" + new Date().getTime().toString();

            $(this.template).attr("id", randId);
            $(this.template).find("[data-type=position_relative_to_buffer]")
                .attr("name", "position_relative_to_buffer_name_" + randId);
        },

        getAppendScope: function () {
            var lastComposite = getTechnologies.call(this)
                .filter(bufferFilter.bind(this))
                .first();

            return buildCompSelector.call(this, lastComposite);
        }
    };

    function TemplateUpdater(template, technologySelectBox) {
        this.template = template;
        this.technologySelectBox = technologySelectBox;
        this.scope = $(this.technologySelectBox).parents('.panel.endpoint');
    }

    return TemplateUpdater;
}());

/*globals ProfileSelectBox*/
var TechnologyTemplate = (function () {
    'use strict';

    function showBuffer() {
        var includes = [];
        this.settings.target.find(".technology[data-composite='true']").each(function () {
            includes = includes.concat($(this).data('includes').split(","));
        });

        return includes.indexOf(this.settings.value) > -1;
    }

    function applyBuffer() {
        if (showBuffer.call(this)) {
            var templateBufferSelect = this.template.find(".editable.buffer select"),
                selectTemplate       = this.settings.target.find(".buffer_template select").clone(true, true);

            templateBufferSelect.replaceWith(selectTemplate);

            this.template.find(".editable.profile, .editable.buffer").toggleClass("hidden");
        }
    }

    function updateBuffers() {
        if (this.settings.composite) {
            var bufferSelect   = this.settings.target.find(".editable.buffer select"),
                selectTemplate = this.settings.target.find(".buffer_template select").clone(true, true);

            bufferSelect.replaceWith(selectTemplate);
        }
    }

    function addCount(value, joinCharacter) {
        if (this.settings.composite) {
            var count = this.settings.target.find(".buffer_template select option").length + 1;
            value = (value + joinCharacter + count);
        }

        return value;
    }

    function addBufferOption() {
        if (this.settings.composite) {
            var option = $("<option/>").attr({
                'value': addCount.call(this, this.settings.value, '_'),
                'data-includes': this.settings.includes
            }).text(this.settings.title);

            this.settings.target.find(".buffer_template select").append(option);
        }
    }

    function updateTemplate() {
        this.settings.title = addCount.call(this, this.settings.title, ' #');

        this.template.find("input").val('');
        this.template.find("strong").text(this.settings.title);

        this.template.attr({
            'class':          this.settings.value + ' technology',
            'data-node':      this.settings.target.data('node'),
            'data-type':      this.settings.value,
            'data-value':     addCount.call(this, this.settings.value, '_'),
            'data-name':      this.settings.title,
            'data-composite': this.settings.composite,
            'data-includes':  this.settings.includes,
            'data-units':     1
        });

        applyBuffer.call(this);
        updateBuffers.call(this);
        addBufferOption.call(this);
    }

    TechnologyTemplate.prototype = {
        addTo: function (callback) {
            updateTemplate.call(this);

            new ProfileSelectBox(this.template[0]).addNew(callback.bind(this.template));

            $(this.settings.target).append(this.template);
        }
    };

    function TechnologyTemplate(settings) {
        this.settings = settings;
        this.template = $("div.technology_template .technology").clone(true, true);
    }

    return TechnologyTemplate;
}());

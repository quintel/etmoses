/*globals ProfileSelectBox,FormHelper*/
var TechnologyTemplate = (function () {
    'use strict';

    /*
     * For every newly added technology it needs to check if the technology is included
     * in the composites.
     */
    function showBuffer() {
        var includes = [];
        this.settings.target.find(".technology[data-composite='true']").each(function () {
            includes = includes.concat($(this).data('includes').split(","));
        });

        return includes.indexOf(this.settings.value) > -1;
    }

    function updateAndToggleBuffer() {
        var templateBufferSelect = this.template.find(".editable.buffer select"),
            selectTemplate       = this.settings.target.find(".buffer_template select").clone(true, true),
            bufferValue          = this.settings.buffer || selectTemplate.val();

        templateBufferSelect.replaceWith(selectTemplate);

        this.template.set("buffer", bufferValue);
        this.template.find(".editable.profile, .editable.buffer").toggleClass("hidden");

        selectTemplate.val(bufferValue);
    }

    function applyBuffer() {
        if (showBuffer.call(this)) {
            updateAndToggleBuffer.call(this);
        }
    }

    function addCount(value, joinCharacter) {
        if (this.settings.composite) {
            var count = this.settings.target.find(".buffer_template select option").length + 1;
            value = (value + joinCharacter + count);
        }

        return value;
    }

    /*
     * Globally update all buffers whenever a new option is added to the template.
     */
    function updateBuffers() {
        var bufferSelect   = this.settings.target.find(".editable.buffer select"),
            selectTemplate = this.settings.target.find(".buffer_template select").clone(true, true);

        bufferSelect.replaceWith(selectTemplate);
    }

    function addBufferOption() {
        if (this.settings.composite) {
            var option = $("<option/>").attr({
                'value': addCount.call(this, this.settings.value, '_'),
                'data-includes': this.settings.includes
            }).text(this.settings.title);

            this.settings.target.find(".buffer_template select").append(option);
            updateBuffers.call(this);
        }
    }

    function setDataAttributes() {
        this.template.attr({
            'data-node':      this.settings.target.data('node'),
            'data-type':      this.settings.value,
            'data-name':      this.settings.title,
            'data-composite': this.settings.composite,
            'data-units':     1
        });

        if (this.settings.composite) {
            this.template.attr({
                'data-composite-value': addCount.call(this, this.settings.value, '_'),
                'data-includes':        FormHelper.includesFor(this.settings.value)
            });
        }
    }

    function updateTemplate() {
        this.settings.title = addCount.call(this, this.settings.title, ' #');

        this.template.find("strong").text(this.settings.title);
        this.template.attr("class", this.settings.value + ' technology');

        setDataAttributes.call(this);
        applyBuffer.call(this);
        addBufferOption.call(this);
    }

    TechnologyTemplate.prototype = {
        addTo: function (callback) {
            this.template = $(".technology_template .technology").clone(true, true);

            updateTemplate.call(this);

            new ProfileSelectBox(this.template[0]).addNew(callback.bind(this.template));

            $(this.settings.target).append(this.template);
        },

        update: function (template) {
            this.template       = $(template);
            this.settings.value = this.settings.composite_value.replace(/\_\d+/, '');
            this.settings.name  = this.settings.name.replace(/\#\d+/, '');
            this.settings.name  = addCount.call(this, this.settings.name, ' #');
            this.settings.title = this.settings.name;

            this.template.find("strong").text(this.settings.name);

            if (this.settings.composite) {
                this.template.data('includes',
                    FormHelper.includesFor(this.settings.type).join(","));
            }

            addBufferOption.call(this);

            if (!this.settings.composite && this.settings.buffer) {
                updateAndToggleBuffer.call(this);
            }
        }
    };

    function TechnologyTemplate(settings) {
        this.settings = settings;
    }

    return TechnologyTemplate;
}());

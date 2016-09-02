/*globals FormHelper*/

var BufferSelectBox = (function () {
    'use strict';

    function createOption() {
        return $("<option/>").attr({
            'value': this.compositeValue,
            'data-includes': this.includes
        }).text(this.name);
    }

    /*
     * If the technology template concerns a composite.
     * It should add an option to the appropriate composite select box.
     */
    function addOptionToBufferTemplate() {
        var newOption,
            data         = $(this.target).data(),
            technology   = data.type,
            bufferSelect = $(".buffer_template select." + technology),
            existing     = $(".editable select.buffer." + technology),
            noOption     = bufferSelect.find("option[value='" +
                               data.compositeValue + "']").length < 1;

        FormHelper.increaseIndex(technology);

        if (noOption) {
            newOption = createOption.call(data);

            bufferSelect.add(existing).append(newOption);
        }
    }

    function reattachBufferingTechnology(e) {
        var value  = $(e.target).val(),
            buffer = $(".technology[data-composite-value='" + value + "']"),
            tech   = $(e.target).parents(".technology");

        tech.set('node', buffer.data('node'));
        buffer.after(tech);
    }

    /*
     * If the technology template concerns a buffer.
     * It should clone the appropriate composite select box.
     * And replace it with the one in his template
     */
    function cloneAndAppendBufferSelect() {
        var buffer       = this.target.getAttribute('data-buffer'),
            compSelector = buffer.replace(/_\d+/, ''),
            template     = $(".buffer_template select." + compSelector)
                             .clone(true, true);

        template.val(buffer);
        template.on("change", reattachBufferingTechnology);

        this.bufferSelect.replaceWith(template);
    }

    function isComposite() {
        return this.target.getAttribute('composite') == 'true';
    }

    BufferSelectBox.prototype = {
        add: function () {
            this.bufferSelect = $(this.target).find(".editable.buffer select");

            if (this.bufferSelect.length > 0) {
                cloneAndAppendBufferSelect.call(this);

                this.bufferSelect
                    .off("change.buffer")
                    .on("change.buffer", reattachBufferingTechnology);
            } else if (isComposite.call(this)) {
                addOptionToBufferTemplate.call(this);
            }
        }
    };

    function BufferSelectBox(target) {
        this.target = target;
    }

    return BufferSelectBox;
}());

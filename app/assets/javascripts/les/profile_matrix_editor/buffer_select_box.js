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
        if (this.techData.composite) {
            var technology   = this.techData.type,
                bufferSelect = $(".buffer_template select." + technology),
                existing     = $(".editable select.buffer." + technology),
                noOption     = bufferSelect.find("option[value='" + this.techData.compositeValue + "']").length < 1;

            FormHelper.increaseIndex(technology);

            if (noOption) {
                bufferSelect.add(existing).append(createOption.call(this.techData));
            }
        }
    }

    /*
     * If the technology template concerns a buffer.
     * It should clone the appropriate composite select box.
     * And replace it with the one in his template
     */
    function cloneAndAppendBufferSelect() {
        if (!!this.techData.buffer) {
            var compositeSelector = this.techData.buffer.replace(/_\d+/, ''),
                template = $(".buffer_template select." + compositeSelector).clone(true, true),
                target = $(this.target).find(".editable.buffer select");

            template.val(this.techData.buffer);
            template.on("change", reattachBufferingTechnology);

            target.replaceWith(template);
        }
    }

    function reattachBufferingTechnology(e) {
        var buffer = $(".technology[data-composite-value='" + $(e.target).val() + "']"),
            tech = $(e.target).parents(".technology");

        buffer.after(tech);
    }

    function addChangeListenerToBufferSelectBox() {
        $(".editable.buffer select").off().on("change", reattachBufferingTechnology);
    }

    BufferSelectBox.prototype = {
        add: function () {
            cloneAndAppendBufferSelect.call(this);
            addOptionToBufferTemplate.call(this);
            addChangeListenerToBufferSelectBox();
        }
    };

    function BufferSelectBox(target) {
        this.target = target;
        this.techData = $(this.target).data();
    }

    return BufferSelectBox;
}());

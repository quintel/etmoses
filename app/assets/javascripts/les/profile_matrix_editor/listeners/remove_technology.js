/*globals AddedTechnologiesValidator*/
var RemoveTechnology = (function () {
    'use strict';

    /*
     * Checks if a technology can be removed from the table.
     * For instance if you want to remove a buffer from the table and it still has
     * technologies attached to it, it should alert the user that that is not possible.
     */
    function removeable() {
        var canBeRemoved = true,
            technology   = $(this).parents(".technology"),
            target       = $(this).parents(".technologies");

        target.find(".technology .buffer select:visible").each(function () {
            if ($(this).val() === technology.data('compositeValue')) {
                canBeRemoved = false;
                return false;
            }
        });

        return canBeRemoved;
    }

    function removeBufferOption() {
        if (this.composite) {
            $(".buffer_template select, .technology .buffer select")
                .selectedOption(this.compositeValue).remove();
        }
    }

    return {
        remove: function (e) {
            e.preventDefault();

            var technology = $(this).parents(".technology");

            if (removeable.call(this)) {
                removeBufferOption.call(technology.data());

                window.currentTechnologiesForm.updateCounter.call(this, false);

                technology.remove();

                AddedTechnologiesValidator.validate();
            } else {
                alert("There are technologies that use this buffer, remove these first before removing this buffer");
            }

            window.currentTechnologiesForm.parseHarmonicaToJSON();
            window.currentTechnologiesForm.markAsEditing();
        }
    };
}());


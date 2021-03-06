var AddedTechnologiesValidator = (function () {
    'use strict';

    /* These methods validate or invalidate the technologies in the slect boxes
     * based on the fact if the buffers are still available.
     */
    function checkSelectBoxes(buffer, possibleOptions) {
        var isDisabled = $(this).parents(".endpoint")
                            .find(".technologies .technology." + buffer).length === 0;

        $(this).find("option")
               .filter(function () { return possibleOptions.test($(this).val()); })
               .prop('disabled', isDisabled);
    }

    return {
        validate: function () {
            var buffer,
                includesJSON = JSON.parse($(".data > .hidden.includes").text());

            for (buffer in includesJSON) {
                $("select.name").each(function () {
                    checkSelectBoxes.call(this, buffer,
                        new RegExp(includesJSON[buffer].join("|")));
                });
            }
        }
    };
}());

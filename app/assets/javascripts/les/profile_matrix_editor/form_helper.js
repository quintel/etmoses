var FormHelper = (function () {
    'use strict';

    return {
        bufferIndexes: {},

        increaseIndex: function (key) {
            if (this.bufferIndexes[key] === undefined) {
                this.bufferIndexes[key] = 1;
            } else {
                this.bufferIndexes[key] += 1;
            }
        },

        includesFor: function (key) {
            var includesJSON = JSON.parse($(".data > .hidden.includes").text());

            return includesJSON[key];
        },

        findBufferDOM: function (settings) {
            return $(settings.target)
                      .find(".technology[data-composite-value='" + settings.buffer + "']")
                      .last();
        }
    };
}());

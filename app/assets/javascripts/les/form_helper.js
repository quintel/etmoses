var FormHelper = (function () {
    'use strict';

    return {
        includesFor: function (key) {
            var includesJSON = JSON.parse($(".data .includes").text());

            return includesJSON[key];
        }
    };
}());

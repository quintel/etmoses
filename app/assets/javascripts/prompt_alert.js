window.customPrompt = function (message, defaultInput, callbackArg) {
    'use strict';

    var popup,
        callback = callbackArg || function () { return; },
        promptMessage = $(".prompt .prompt-message");

    $(".prompt .message").text(message);
    promptMessage.val('').val(defaultInput);

    popup = $.featherlight($(".prompt"));

    $(".prompt .save").off('click').on('click', function () {
        var currentValue = $(".featherlight-content .prompt .prompt-message").val();
        callback.call(this, currentValue);
        popup.close();
    });
};

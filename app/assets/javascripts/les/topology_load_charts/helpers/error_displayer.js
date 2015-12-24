var ErrorDisplayer = (function(){
    'use strict';

    var error, target,
        errorEl    = $('<div class="error"></div>'),
        messageEl  = $('<div class="message"></div>'),
        detailEl   = $('<div class="detail"></div>'),
        backtracEl = $('<pre class="backtrace"></pre>');

    function displayMessage(){
        if(error.message){
            errorEl.append(detailEl.text(error.message))
        }
    }

    function displayBacktrace(){
        if(error.backtrace){
            errorEl.append(backtracEl.html(error.backtrace.join('<br/>')));
        }
    }

    ErrorDisplayer.prototype = {
        displayError: function(){
            $('.loading').remove();
            $(target).append(errorEl.append(messageEl.text(error.error)));
            displayMessage();
            displayBacktrace();
        }
    };

    function ErrorDisplayer(_error, _target){
        error = _error;
        target = _target;
    }

    return ErrorDisplayer;
})();

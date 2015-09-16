var ErrorDisplayer = (function(){
  var error, target;
  var errorEl    = $('<div class="error"></div>');
  var messageEl  = $('<div class="message"></div>');
  var detailEl   = $('<div class="detail"></div>');
  var backtracEl = $('<pre class="backtrace"></pre>');

  ErrorDisplayer.prototype = {
    displayError: function(){
      $('.loading').remove();
      $(target).append(errorEl.append(messageEl.text(error.error)));
      displayMessage();
      displayBacktrace();
    }
  };

  function displayMessage(){
    if(error.message){
      errorEl.append(detailEl.text(error.message))
    }
  };

  function displayBacktrace(){
    if(error.backtrace){
      errorEl.append(backtracEl.html(error.backtrace.join('<br/>')));
    }
  };

  function ErrorDisplayer(_error, _target){
    error = _error;
    target = _target;
  };

  return ErrorDisplayer;
})();

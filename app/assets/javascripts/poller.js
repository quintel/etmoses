var Poller = (function(){
  var pollTime = 1000;

  Poller.prototype = {
    poll: function(){
      this.create($.extend(this.first_data, this.data));
      this.hooks.pending();
    },
    create: function(data){
      $.ajax({
        type:         "POST",
        contentType:  "application/json",
        dataType:     "json",
        url:          this.url,
        data:         JSON.stringify(data),
        success:      success.bind(this)
      });
    }
  };

  function success(data){
    if(data.pending){
      this.hooks.pending();

      this.timeout = setTimeout(onTimeout.bind(this), pollTime);
    }
    else{
      this.hooks.final_success(data);

      clearTimeout(this.timeout);
    };
  };

  function onTimeout(){
    this.create(this.data);
    clearTimeout(this.timeout);
  };

  function blankHooks(){
    return {
      final_success: function(){},
      pending:       function(){}
    };
  };

  /*
   * Poller (url [String], _data [Object], _first_data [Object], _hooks [Object]
   * Poller is an ajax loop that keeps looping until it no longer receives pending from
   * the server.
   *
   * _first_data is data that will only be send the first time.
   *
   * */

  function Poller(_options){
    this.url           = _options.url;
    this.data          = _options.data || {};
    this.first_data    = _options.first_data || {};
    this.hooks         = $.extend(blankHooks(), _options.hooks);

    this.timeout       = null;
  };

  return Poller;
})();

var Poller = (function(){
  var pollTime = 1000;

  Poller.prototype = {
    deferred: null,
    poll: function(){
      this.deferred = $.Deferred();
      this.create($.extend(this.first_data, this.data));

      return this.deferred.promise();
    },
    create: function(data){
      if (! this.firstRequestAt) {
        this.firstRequestAt = new Date();
      }

      $.ajax({
        type:         "POST",
        contentType:  "application/json",
        dataType:     "json",
        url:          this.url,
        data:         JSON.stringify(data),
        success:      success.bind(this),
        error:        fail.bind(this)
      });
    }
  };

  function fail(e, f){
    this.deferred.reject(e, f);

    clearTimeout(this.timeout);
  };

  function success(data){
    var nextPollTime = pollTime;

    if(data.pending){
      if ((new Date()) - this.firstRequestAt > this.slower) {
        // After "this.slower" ms have elapsed, start polling at a slower rate.
        nextPollTime = pollTime * 2;
      }

      this.timeout = setTimeout(onTimeout.bind(this), nextPollTime);
    }
    else{
      this.deferred.resolve(data);

      clearTimeout(this.timeout);
    };
  };

  function onTimeout(){
    this.create(this.data);
    this.deferred.notify();

    clearTimeout(this.timeout);
  };

  /*
   * Poller (url [String], _data [Object], _first_data [Object]
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
    this.slower        = _options.slower || 10000;

    this.timeout       = null;
  };

  return Poller;
})();

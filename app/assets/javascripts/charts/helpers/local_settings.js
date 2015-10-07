var LocalSettings = (function(){
  LocalSettings.prototype = {
    set: function(key, value){
      var settings = read.call(this);
      settings[key] = value;
      write.call(this, settings);
    },

    get: function(key){
      return read.call(this)[key];
    },

    getAll: function(){
      return read.call(this);
    }
  };

  function write(value){
    if(isSupportingLocalStorage() && value !== null){
      window.localStorage.setItem(this.testingGroundId, JSON.stringify(value));
    }
  };

  function read(){
    if(isSupportingLocalStorage()){
      return JSON.parse(window.localStorage.getItem(this.testingGroundId));
    };
  };

  function isSupportingLocalStorage(){
    try {
      return 'localStorage' in window && window['localStorage'] !== null;
    }
    catch(e) {
      return false;
    };
  };

  function LocalSettings(_testingGroundId){
    this.testingGroundId = _testingGroundId;
    write.call(this, read.call(this) || {});
  };

  return LocalSettings;
})();

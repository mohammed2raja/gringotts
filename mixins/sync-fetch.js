(function() {
  define(function(require) {
    var advice, syncFetch;
    advice = require('flight/advice');
    syncFetch = function() {
      if (this.beginSync) {
        this.beginSync();
        return this.on('sync', this.finishSync, this);
      }
    };
    return function() {
      this.before('fetch', syncFetch);
      return this;
    };
  });

}).call(this);

(function() {
  define(function(require, exports) {
    var advice, syncFetch;
    advice = require('flight/advice');
    syncFetch = function() {
      if (this.beginSync) {
        this.beginSync();
        return this.on('sync', this.finishSync, this);
      }
    };
    return exports = function() {
      this.before('fetch', syncFetch);
      return this;
    };
  });

}).call(this);

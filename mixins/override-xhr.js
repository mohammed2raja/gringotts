(function() {
  define(function(require) {
    return {

      /**
       * Aborts the existing request if a new one is being requested.
       */
      overrideXHR: function(promise) {
        if (this.currentXHR && this.isSyncing()) {
          this.currentXHR.abort();
        }
        return this.currentXHR = promise;
      }
    };
  });

}).call(this);

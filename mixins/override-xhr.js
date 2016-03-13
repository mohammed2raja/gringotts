(function() {
  define(function(require) {
    return {

      /**
       * Aborts the existing request if a new one is being requested.
       */
      overrideXHR: function($xhr) {
        if (this.currentXHR && this.isSyncing()) {
          this.currentXHR.abort();
        }
        return this.currentXHR = $xhr;
      }
    };
  });

}).call(this);

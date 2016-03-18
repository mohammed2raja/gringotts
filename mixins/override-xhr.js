(function() {
  define(function(require) {
    return {

      /**
       * Aborts the existing request if a new one is being requested.
       */
      overrideXHR: function($xhr) {
        var base;
        if (this.currentXHR && this.isSyncing()) {
          if (typeof (base = this.currentXHR).abort === "function") {
            base.abort();
          }
        }
        return this.currentXHR = $xhr;
      }
    };
  });

}).call(this);

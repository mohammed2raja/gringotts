(function() {
  define(function(require) {
    return {

      /**
       * Creates a promise that is never resolved, so niether of chain callbacks
       * is called. This is useful for mocking in unit testing.
       */
      create: function() {
        return $.Deferred().promise();
      }
    };
  });

}).call(this);

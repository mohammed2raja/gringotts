(function() {
  define(function(require) {
    return {
      safeSyncCallback: function(method, model, options) {
        if (!options) {
          return;
        }
        return _.each(['success', 'error', 'complete'], function(cb) {
          var callback, ctx;
          callback = options[cb];
          if (callback) {
            ctx = options.context || this;
            return options[cb] = (function(_this) {
              return function() {
                if (!_this.disposed) {
                  return callback.apply(ctx, arguments);
                }
              };
            })(this);
          }
        }, this);
      }
    };
  });

}).call(this);

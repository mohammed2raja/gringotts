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
      },
      safeDeferred: function($xhr) {
        var deferred, filter;
        if (!$xhr) {
          return;
        }
        filter = (function(_this) {
          return function() {
            if (_this.disposed) {
              $xhr.errorHandled = true;
              return $.Deferred();
            } else {
              return $xhr;
            }
          };
        })(this);
        deferred = $xhr.then(filter, filter, filter).promise();
        deferred.abort = function() {
          return $xhr.abort();
        };
        return deferred;
      }
    };
  });

}).call(this);

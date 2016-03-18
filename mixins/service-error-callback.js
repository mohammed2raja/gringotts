(function() {
  define(function(require) {
    return {
      serviceErrorCallback: function(method, model, options) {
        var callback;
        if (!options) {
          return;
        }
        callback = options.error;
        return options.error = (function(_this) {
          return function($xhr) {
            var ctx;
            if ($xhr.status !== 0 || $xhr.statusText === 'error') {
              ctx = options.context || _this;
              if (callback != null) {
                callback.apply(ctx, arguments);
              }
              if (typeof _this.abortSync === "function") {
                _this.abortSync();
              }
              return _this.trigger('service-unavailable');
            }
          };
        })(this);
      }
    };
  });

}).call(this);

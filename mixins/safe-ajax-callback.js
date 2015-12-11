(function() {
  define(function(require) {
    var advice, safeAjaxCallback, _;
    _ = require('underscore');
    advice = require('flight/advice');
    safeAjaxCallback = function(method, collection, opts) {
      if (opts == null) {
        opts = {};
      }
      return _.each(['success', 'error', 'complete'], function(val) {
        var callback, ctx;
        callback = opts[val];
        if (callback) {
          ctx = opts.context || this;
          return opts[val] = (function(_this) {
            return function() {
              if (!_this.disposed) {
                return callback.apply(ctx, arguments);
              }
            };
          })(this);
        }
      }, this);
    };
    return function() {
      this.before('sync', safeAjaxCallback);
      return this;
    };
  });

}).call(this);

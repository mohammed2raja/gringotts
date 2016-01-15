(function() {
  define(function(require) {
    var _, serviceErrorCallback, utils;
    _ = require('underscore');
    utils = require('lib/utils');
    serviceErrorCallback = function(method, collection, opts) {
      var callback;
      if (opts == null) {
        opts = {};
      }
      callback = opts.error;
      return opts.error = (function(_this) {
        return function($xhr) {
          var status;
          status = $xhr.status;
          if (status !== 0) {
            if (callback != null) {
              callback.apply(opts.context || opts, arguments);
            }
            if (typeof _this.abortSync === "function") {
              _this.abortSync();
            }
            return _this.trigger('service-unavailable');
          }
        };
      })(this);
    };
    return function() {
      this.before('sync', serviceErrorCallback);
      return this;
    };
  });

}).call(this);

(function() {
  define(function(require, exports) {
    var serviceErrorCallback, serviceUnavailableCallback, utils, _;
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
          var error, status;
          status = $xhr.status;
          if (status !== 0) {
            if (callback != null) {
              callback.apply(opts.context || opts, arguments);
            }
            if (typeof _this.abortSync === "function") {
              _this.abortSync();
            }
            _this.trigger('service-unavailable');
            if (status !== 418) {
              error = (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.notification') : void 0) || "There was a problem communicating with the server.";
              return _this.publishEvent('notify', error, {
                classes: 'alert-danger'
              });
            }
          }
        };
      })(this);
    };
    serviceUnavailableCallback = function(method, collection, opts) {
      var callback, _ref;
      if (opts == null) {
        opts = {};
      }
      callback = (_ref = opts.statusCode) != null ? _ref['418'] : void 0;
      opts.statusCode || (opts.statusCode = {});
      return _.extend(opts.statusCode, {
        418: (function(_this) {
          return function($xhr) {
            var errorState, message;
            if (callback != null) {
              callback.apply(opts.context || opts, arguments);
            }
            errorState = utils.parseJSON($xhr.responseText);
            message = errorState.message || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.service') : void 0) || "There was an error communicating with the server.";
            return _this.publishEvent('notify', message, {
              classes: 'alert-danger',
              reqTimeout: 10000
            });
          };
        })(this)
      });
    };
    return exports = function() {
      this.before('sync', serviceErrorCallback);
      this.before('sync', serviceUnavailableCallback);
      return this;
    };
  });

}).call(this);

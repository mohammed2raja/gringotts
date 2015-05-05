(function() {
  define(function(require, exports) {
    var DEFAULTS, advice, utils, _;
    _ = require('underscore');
    utils = require('../lib/utils');
    advice = require('flight/advice');
    DEFAULTS = {
      classes: 'alert-danger',
      reqTimeout: 10000
    };
    return exports = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.before('delegateListeners', function() {
        var evtOpts, message, route;
        message = opts.message;
        route = opts.route || '';
        evtOpts = opts.evtOpts ? _.defaults(opts.evtOpts, DEFAULTS) : DEFAULTS;
        return this.delegateListener('error', 'model', function(model, $xhr) {
          var id, status;
          id = model.id;
          status = $xhr.status;
          if (status === 403 || status === 404) {
            if (typeof message === 'function') {
              message = message(model);
            }
            message || (message = "The model " + id + " could not be accessed.");
            utils.redirectTo(route);
            return this.publishEvent('notify', message, evtOpts);
          }
        });
      });
      return this;
    };
  });

}).call(this);

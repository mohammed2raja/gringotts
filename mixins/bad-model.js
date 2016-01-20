(function() {
  define(function(require) {
    var DEFAULTS, _, advice, utils;
    _ = require('underscore');
    utils = require('../lib/utils');
    advice = require('flight/advice');
    DEFAULTS = {
      classes: 'alert-danger',
      reqTimeout: 10000
    };
    return function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.before('delegateListeners', function() {
        var evtOpts, message, route;
        message = opts.message;
        route = opts.route || '';
        evtOpts = opts.evtOpts ? _.defaults(opts.evtOpts, DEFAULTS) : DEFAULTS;
        return this.delegateListener('error', 'model', function(model, $xhr) {
          var args, id, status;
          id = model.id;
          status = $xhr.status;
          if (status === 400 || status === 403 || status === 404) {
            if (typeof message === 'function') {
              message = message(model);
            }
            message || (message = "The model " + id + " could not be accessed.");
            args = (typeof route === "function" ? route(model) : void 0) || route;
            if (!_.isArray(args)) {
              args = [args];
            }
            utils.redirectTo.apply(utils, args);
            this.publishEvent('notify', message, evtOpts);
            return $xhr.errorHandled = true;
          }
        });
      });
      return this;
    };
  });

}).call(this);

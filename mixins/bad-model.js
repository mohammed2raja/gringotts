(function() {
  define(function(require) {
    var utils;
    utils = require('../lib/utils');
    return {
      badModelOpts: {},
      badModelHandler: function(model, $xhr) {
        var args, message, ref, ref1, route;
        ref = this.badModelOpts, message = ref.message, route = ref.route;
        if ((ref1 = $xhr.status) === 403 || ref1 === 404) {
          message = (typeof message === "function" ? message(model) : void 0) || message || ("The model " + model.id + " could not be accessed.");
          args = (typeof route === "function" ? route(model) : void 0) || route || '';
          if (!_.isArray(args)) {
            args = [args];
          }
          utils.redirectTo.apply(utils, args);
          this.publishEvent('notify', message, {
            classes: 'alert-danger'
          });
          return $xhr.errorHandled = true;
        }
      }
    };
  });

}).call(this);

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var utils;
    utils = require('../lib/utils');
    return function(superclass) {
      var BadModel;
      return BadModel = (function(superClass) {
        extend(BadModel, superClass);

        function BadModel() {
          return BadModel.__super__.constructor.apply(this, arguments);
        }

        BadModel.prototype.badModelOpts = {};

        BadModel.prototype.listen = {
          'error model': 'onError'
        };

        BadModel.prototype.onError = function(model, $xhr) {
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
        };

        return BadModel;

      })(superclass);
    };
  });

}).call(this);

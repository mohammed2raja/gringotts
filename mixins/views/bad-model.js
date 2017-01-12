(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ErrorHandling, helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');
    ErrorHandling = require('./error-handling');
    return function(base) {
      var BadModel;
      return BadModel = (function(superClass) {
        extend(BadModel, superClass);

        function BadModel() {
          return BadModel.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(BadModel.prototype, 'BadModel');

        BadModel.prototype.badModelOpts = {};

        BadModel.prototype.initialize = function() {
          helper.assertViewOrCollectionView(this);
          return BadModel.__super__.initialize.apply(this, arguments);
        };

        BadModel.prototype.handle403 = function($xhr) {
          return this.handleBadModel($xhr);
        };

        BadModel.prototype.handleAny = function($xhr) {
          return this.handleBadModel($xhr);
        };

        BadModel.prototype.handleBadModel = function($xhr) {
          var args, message, ref, ref1, route;
          ref = this.badModelOpts, message = ref.message, route = ref.route;
          if ((ref1 = $xhr.status) === 403 || ref1 === 404) {
            message = (typeof message === "function" ? message(this.model) : void 0) || message || ("The model " + this.model.id + " could not be accessed.");
            args = (typeof route === "function" ? route(this.model) : void 0) || route || '';
            if (!_.isArray(args)) {
              args = [args];
            }
            utils.redirectTo.apply(utils, args);
            this.publishEvent('notify', message, {
              classes: 'alert-danger'
            });
            return this.markAsHandled($xhr);
          }
        };

        return BadModel;

      })(utils.mix(base)["with"](ErrorHandling));
    };
  });

}).call(this);

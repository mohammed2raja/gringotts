(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, Model, activeSyncMachine, advice, overrideXHR, safeSyncCallback;
    Chaplin = require('chaplin');
    advice = require('../../mixins/advice');
    activeSyncMachine = require('../../mixins/active-sync-machine');
    overrideXHR = require('../../mixins/override-xhr');
    safeSyncCallback = require('../../mixins/safe-sync-callback');
    return Model = (function(superClass) {
      extend(Model, superClass);

      function Model() {
        return Model.__super__.constructor.apply(this, arguments);
      }

      _.extend(Model.prototype, activeSyncMachine, safeSyncCallback, overrideXHR);

      advice.call(Model.prototype);

      Model.prototype.initialize = function() {
        Model.__super__.initialize.apply(this, arguments);
        return this.activateSyncMachine();
      };

      Model.prototype.save = function(key, val, options) {
        return Model.__super__.save.apply(this, arguments) || $.Deferred().reject({
          error: this.validationError
        }).always((function(_this) {
          return function() {
            if (!_this.validationError) {
              return;
            }
            return _this.publishEvent('notify', _this.validationError[key] || (_.isObject(_this.validationError) ? _.first(_.values(_this.validationError)) : _this.validationError), {
              classes: 'alert-danger'
            });
          };
        })(this)).promise();
      };

      Model.prototype.sync = function() {
        this.safeSyncCallback.apply(this, arguments);
        return this.safeDeferred(Model.__super__.sync.apply(this, arguments));
      };

      Model.prototype.fetch = function() {
        return this.overrideXHR(Model.__super__.fetch.apply(this, arguments));
      };

      return Model;

    })(Chaplin.Model);
  });

}).call(this);

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Abortable, ActiveSyncMachine, Chaplin, Model, SafeSyncCallback, WithHeaders, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    ActiveSyncMachine = require('../../mixins/models/active-sync-machine');
    Abortable = require('../../mixins/models/abortable');
    SafeSyncCallback = require('../../mixins/models/safe-sync-callback');
    WithHeaders = require('../../mixins/models/with-headers');
    return Model = (function(superClass) {
      extend(Model, superClass);

      function Model() {
        return Model.__super__.constructor.apply(this, arguments);
      }

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

      return Model;

    })(utils.mix(Chaplin.Model)["with"](WithHeaders, ActiveSyncMachine, Abortable, SafeSyncCallback));
  });

}).call(this);

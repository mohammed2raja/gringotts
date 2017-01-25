(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Abortable, ActiveSyncMachine, Chaplin, ErrorHandled, Model, SafeSyncCallback, WithHeaders;
    Chaplin = require('chaplin');
    ActiveSyncMachine = require('../../mixins/models/active-sync-machine');
    Abortable = require('../../mixins/models/abortable');
    SafeSyncCallback = require('../../mixins/models/safe-sync-callback');
    ErrorHandled = require('../../mixins/models/error-handled');
    WithHeaders = require('../../mixins/models/with-headers');

    /**
     *  Abstract class for models. Includes useful mixins by default.
     */
    return Model = (function(superClass) {
      extend(Model, superClass);

      function Model() {
        return Model.__super__.constructor.apply(this, arguments);
      }

      Model.prototype.save = function(key, val, options) {
        var message, promise;
        promise = Model.__super__.save.apply(this, arguments) || $.Deferred();
        if (this.validationError) {
          message = this.validationError[key] || (_.isObject(this.validationError) ? _.first(_.values(this.validationError)) : this.validationError);
          return promise.reject(new Error(message));
        } else {
          return promise;
        }
      };

      return Model;

    })(ActiveSyncMachine(ErrorHandled(WithHeaders(Abortable(SafeSyncCallback(Chaplin.Model))))));
  });

}).call(this);

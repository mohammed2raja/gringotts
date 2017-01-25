(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Abortable, ActiveSyncMachine, Chaplin, Collection, ErrorHandled, Model, SafeSyncCallback, ServiceErrorHandled, WithHeaders;
    Chaplin = require('chaplin');
    ActiveSyncMachine = require('../../mixins/models/active-sync-machine');
    Abortable = require('../../mixins/models/abortable');
    SafeSyncCallback = require('../../mixins/models/safe-sync-callback');
    ErrorHandled = require('../../mixins/models/error-handled');
    ServiceErrorHandled = require('../../mixins/models/service-error-handled');
    WithHeaders = require('../../mixins/models/with-headers');
    Model = require('./model');

    /**
     *  Abstract class for collections. Includes useful mixins by default.
     */
    return Collection = (function(superClass) {
      extend(Collection, superClass);

      function Collection() {
        return Collection.__super__.constructor.apply(this, arguments);
      }

      Collection.prototype.model = Model;

      return Collection;

    })(ActiveSyncMachine(ServiceErrorHandled(ErrorHandled(WithHeaders(Abortable(SafeSyncCallback(Chaplin.Collection)))))));
  });

}).call(this);

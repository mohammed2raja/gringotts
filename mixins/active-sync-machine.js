(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin;
    Chaplin = require('chaplin');
    return function(superclass) {
      var ActiveSyncMachine;
      return ActiveSyncMachine = (function(superClass) {
        extend(ActiveSyncMachine, superClass);

        function ActiveSyncMachine() {
          return ActiveSyncMachine.__super__.constructor.apply(this, arguments);
        }

        _.extend(ActiveSyncMachine.prototype, Chaplin.SyncMachine);

        ActiveSyncMachine.prototype.initialize = function() {
          ActiveSyncMachine.__super__.initialize.apply(this, arguments);
          return this.activateSyncMachine();
        };


        /**
         * Activates Chaplin.SyncMachine on an object
         * @param  {Backbone.Events} obj an instinace of Model or Collection
         * @param  {Bool} listenAll to listen events from nested models
         */

        ActiveSyncMachine.prototype.activateSyncMachine = function(listenAll) {
          if (listenAll == null) {
            listenAll = false;
          }
          if (!this.on) {
            throw new Error('obj must have Backbone.Events mixed-in');
          }
          return _.each([
            {
              event: 'request',
              listener: 'beginSync'
            }, {
              event: 'sync',
              listener: 'finishSync'
            }, {
              event: 'error',
              listener: 'unsync'
            }
          ], function(map) {
            return this.on(map.event, function(model) {
              if (this === model || listenAll) {
                return this[map.listener]();
              }
            });
          }, this);
        };

        return ActiveSyncMachine;

      })(superclass);
    };
  });

}).call(this);

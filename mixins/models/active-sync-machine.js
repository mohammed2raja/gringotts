(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, EVENT_MAP, STATE_MAP, helper, switchStateTo;
    Chaplin = require('chaplin');
    helper = require('../../lib/mixin-helper');
    EVENT_MAP = [
      {
        event: 'request',
        method: 'beginSync'
      }, {
        event: 'sync',
        method: 'finishSync'
      }, {
        event: 'error',
        method: 'unsync'
      }
    ];
    STATE_MAP = {
      syncing: 'beginSync',
      synced: 'finishSync',
      unsynced: 'unsync'
    };
    switchStateTo = function(target, state) {
      return target[STATE_MAP[state]]();
    };
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var ActiveSyncMachine;
        return ActiveSyncMachine = (function(superClass) {
          extend(ActiveSyncMachine, superClass);

          function ActiveSyncMachine() {
            return ActiveSyncMachine.__super__.constructor.apply(this, arguments);
          }

          _.extend(ActiveSyncMachine.prototype, Chaplin.SyncMachine);

          helper.setTypeName(ActiveSyncMachine.prototype, 'ActiveSyncMachine');

          ActiveSyncMachine.prototype.initialize = function() {
            helper.assertModelOrCollection(this);
            ActiveSyncMachine.__super__.initialize.apply(this, arguments);
            return this.activateSyncMachine();
          };


          /**
           * Activates SyncMachine on current model or collection.
           */

          ActiveSyncMachine.prototype.activateSyncMachine = function() {
            return this.bindSyncMachineTo(this);
          };


          /**
           * Binds current model SyncMachine to a source model.
           * @param  {Model|Collection}   source
           * @param  {Object}             options, listenAll: true to listen events
           *                                       from nested models
           */

          ActiveSyncMachine.prototype.bindSyncMachineTo = function(source, options) {
            options = _.defaults({}, options, {
              listenAll: false
            });
            return _.each(EVENT_MAP, (function(_this) {
              return function(entry) {
                return _this.listenTo(source, entry.event, function(target) {
                  if (target === source || options.listenAll) {
                    return this[entry.method]();
                  }
                });
              };
            })(this));
          };


          /**
           * Unbinds current model SyncMachine from a source model.
           */

          ActiveSyncMachine.prototype.unbindSyncMachineFrom = function(source) {
            return _.each(EVENT_MAP, (function(_this) {
              return function(entry) {
                return _this.stopListening(source, entry.event);
              };
            })(this));
          };


          /**
           * Links current model SyncMachine to another model SyncMachine.
           * @param  {Model|Collection} source  with SyncMachine.
           */

          ActiveSyncMachine.prototype.linkSyncMachineTo = function(source) {
            if (!_.isFunction(source != null ? source.syncState : void 0)) {
              return;
            }
            if (this.syncState() !== source.syncState()) {
              switchStateTo(this, source.syncState());
            }
            return this.listenTo(source, 'syncStateChange', function(source, state) {
              return switchStateTo(this, state);
            });
          };


          /**
           * Unlinks current model SyncMachine from another model SyncMachine.
           */

          ActiveSyncMachine.prototype.unlinkSyncMachineFrom = function(source) {
            return this.stopListening(source, 'syncStateChange');
          };

          return ActiveSyncMachine;

        })(superclass);
      });
    };
  });

}).call(this);

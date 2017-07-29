(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require) {
    var ActiveSyncMachine, Backbone, ShadowSyncMachine, helper, isPerhapsSynced;
    Backbone = require('backbone');
    helper = require('../../lib/mixin-helper');
    ActiveSyncMachine = require('../../mixins/models/active-sync-machine');
    isPerhapsSynced = function(collection) {
      if (_.isFunction(collection != null ? collection.isSynced : void 0)) {
        return collection.isSynced();
      } else {
        return true;
      }
    };
    ShadowSyncMachine = (function(superClass) {
      extend(ShadowSyncMachine, superClass);

      function ShadowSyncMachine() {
        return ShadowSyncMachine.__super__.constructor.apply(this, arguments);
      }

      _.extend(ShadowSyncMachine.prototype, Backbone.Events);

      return ShadowSyncMachine;

    })(ActiveSyncMachine((function() {})));

    /**
     * Helps synchronize sync state of a collection and it's children collections.
     * This mixin works the best when applied to Collections that serve as a
     * filter groups source of the FilterInputView control.
     */
    return function(superclass) {
      var SyncDeeply;
      return SyncDeeply = (function(superClass) {
        extend(SyncDeeply, superClass);

        function SyncDeeply() {
          this.onDeepSyncStateChange = bind(this.onDeepSyncStateChange, this);
          return SyncDeeply.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(SyncDeeply.prototype, 'SyncDeeply');

        SyncDeeply.prototype.initialize = function() {
          helper.assertCollection(this);
          SyncDeeply.__super__.initialize.apply(this, arguments);
          this.unbindSyncMachineFrom(this);
          this.shadowSyncMachine = new ShadowSyncMachine();
          this.shadowSyncMachine.bindSyncMachineTo(this);
          this.addDeepListener(this.shadowSyncMachine);
          this.on('add', function(model) {
            return this.addDeepListener(model.get('children'));
          });
          return this.on('remove', function(model) {
            return this.removeDeepListener(model.get('children'));
          });
        };

        SyncDeeply.prototype.reset = function() {
          SyncDeeply.__super__.reset.apply(this, arguments);
          return this.each((function(_this) {
            return function(model) {
              return _this.addDeepListener(model.get('children'));
            };
          })(this));
        };

        SyncDeeply.prototype.fetchChildren = function() {
          return $.when.apply(this, this.reduce(function(promises, model) {
            var children;
            if (_.result((children = model.get('children')), 'url')) {
              promises.push(children.fetch());
            }
            return promises;
          }, []));
        };

        SyncDeeply.prototype.isSynced = function() {
          return this.shadowSyncMachine.isSynced() && this.reduce(function(synced, model) {
            return synced && isPerhapsSynced(model.get('children'));
          }, true);
        };

        SyncDeeply.prototype.addDeepListener = function(collection) {
          return collection != null ? collection.on('syncStateChange', this.onDeepSyncStateChange) : void 0;
        };

        SyncDeeply.prototype.removeDeepListener = function(collection) {
          return collection != null ? collection.off('syncStateChange', this.onDeepSyncStateChange) : void 0;
        };

        SyncDeeply.prototype.onDeepSyncStateChange = function(collection, syncState) {
          if (syncState === 'syncing' && !this.errorHappened) {
            return this.beginSync();
          } else if (syncState === 'synced' && this.isSynced()) {
            return this.finishSync();
          } else if (syncState === 'unsynced') {
            this.errorHappened = true;
            return this.unsync();
          }
        };

        SyncDeeply.prototype.dispose = function() {
          this.removeDeepListener(this.shadowSyncMachine);
          this.each((function(_this) {
            return function(model) {
              return _this.removeDeepListener(model.get('children'));
            };
          })(this));
          return SyncDeeply.__super__.dispose.apply(this, arguments);
        };

        return SyncDeeply;

      })(ActiveSyncMachine(superclass));
    };
  });

}).call(this);

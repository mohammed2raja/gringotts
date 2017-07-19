(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, isPerhapsSynced;
    helper = require('../../lib/mixin-helper');
    isPerhapsSynced = function(collection) {
      if (_.isFunction(collection != null ? collection.isSynced : void 0)) {
        return collection.isSynced();
      } else {
        return true;
      }
    };

    /**
     * Helps synchronize sync state of a collection and it's children collections.
     * This mixin works the best when applied to Collections that serve as a
     * filter groups source of the FilterInputView control.
     */
    return function(superclass) {
      var FilterGrouped;
      return FilterGrouped = (function(superClass) {
        extend(FilterGrouped, superClass);

        function FilterGrouped() {
          this.triggerSyncDeep = bind(this.triggerSyncDeep, this);
          return FilterGrouped.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(FilterGrouped.prototype, 'FilterGrouped');

        FilterGrouped.prototype.initialize = function() {
          helper.assertCollection(this);
          FilterGrouped.__super__.initialize.apply(this, arguments);
          this.addSyncDeepListener(this);
          this.on('add', function(model) {
            return this.addSyncDeepListener(model.get('children'));
          });
          return this.on('remove', function(model) {
            return this.removeSyncDeepListener(model.get('children'));
          });
        };

        FilterGrouped.prototype.reset = function() {
          FilterGrouped.__super__.reset.apply(this, arguments);
          return this.each((function(_this) {
            return function(model) {
              return _this.addSyncDeepListener(model.get('children'));
            };
          })(this));
        };

        FilterGrouped.prototype.fetchChildren = function() {
          return $.when.apply(this, this.reduce(function(promises, model) {
            var children;
            if (_.result((children = model.get('children')), 'url')) {
              promises.push(children.fetch());
            }
            return promises;
          }, []));
        };

        FilterGrouped.prototype.isSyncedDeep = function() {
          return isPerhapsSynced(this) && this.reduce(function(synced, model) {
            return synced && isPerhapsSynced(model.get('children'));
          }, true);
        };

        FilterGrouped.prototype.addSyncDeepListener = function(collection) {
          return collection != null ? collection.on('sync', this.triggerSyncDeep) : void 0;
        };

        FilterGrouped.prototype.removeSyncDeepListener = function(collection) {
          return collection != null ? collection.off('sync', this.triggerSyncDeep) : void 0;
        };

        FilterGrouped.prototype.triggerSyncDeep = function() {
          if (this.isSyncedDeep()) {
            return this.trigger('syncDeep', this);
          }
        };

        FilterGrouped.prototype.dispose = function() {
          this.each(function(model) {
            var ref;
            return (ref = model.get('children')) != null ? ref.dispose() : void 0;
          });
          return FilterGrouped.__super__.dispose.apply(this, arguments);
        };

        return FilterGrouped;

      })(superclass);
    };
  });

}).call(this);

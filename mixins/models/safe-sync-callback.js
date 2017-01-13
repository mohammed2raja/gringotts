(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');

    /**
     * This mixin prevent errors when sync/fetch callback executes after
      * route change when model is disposed.
     */
    return function(superclass) {
      var SafeSyncCallback;
      return SafeSyncCallback = (function(superClass) {
        extend(SafeSyncCallback, superClass);

        function SafeSyncCallback() {
          return SafeSyncCallback.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(SafeSyncCallback.prototype, 'SafeSyncCallback');

        SafeSyncCallback.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          return SafeSyncCallback.__super__.initialize.apply(this, arguments);
        };

        SafeSyncCallback.prototype.sync = function() {
          this.safeSyncHashCallbacks.apply(this, arguments);
          return utils.disposable(SafeSyncCallback.__super__.sync.apply(this, arguments), (function(_this) {
            return function() {
              return _this.disposed;
            };
          })(this));
        };


        /**
         * Piggies back off the AJAX option hash which the Backbone
          * server methods (such as `fetch` and `save`) use.
         */

        SafeSyncCallback.prototype.safeSyncHashCallbacks = function(method, model, options) {
          if (!options) {
            return;
          }
          return _.each(['success', 'error', 'complete'], (function(_this) {
            return function(cb) {
              var callback, ctx;
              callback = options[cb];
              if (callback) {
                ctx = options.context || _this;
                return options[cb] = function() {
                  if (!_this.disposed) {
                    return callback.apply(ctx, arguments);
                  }
                };
              }
            };
          })(this));
        };

        return SafeSyncCallback;

      })(superclass);
    };
  });

}).call(this);

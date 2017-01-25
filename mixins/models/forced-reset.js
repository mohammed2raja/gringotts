(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var SafeSyncCallback, helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');
    SafeSyncCallback = require('./safe-sync-callback');

    /**
     * Forces reseting all models in collection upon failed ajax request.
     * This is required for Sorted or Paginated collections,
     * to clear current items if new page request or new sort ajax request failed.
     */
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var ForcedReset;
        return ForcedReset = (function(superClass) {
          extend(ForcedReset, superClass);

          function ForcedReset() {
            return ForcedReset.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(ForcedReset.prototype, 'ForcedReset');

          ForcedReset.prototype.initialize = function() {
            helper.assertCollection(this);
            helper.assertNotModel(this);
            return ForcedReset.__super__.initialize.apply(this, arguments);
          };

          ForcedReset.prototype.fetch = function() {
            return utils.abortable(ForcedReset.__super__.fetch.apply(this, arguments), {
              "catch": (function(_this) {
                return function($xhr) {
                  _this.reset();
                  return $xhr;
                };
              })(this)
            });
          };

          return ForcedReset;

        })(SafeSyncCallback(superclass));
      });
    };
  });

}).call(this);

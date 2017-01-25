(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ForcedReset, Queryable, SafeSyncCallback, helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');
    SafeSyncCallback = require('./safe-sync-callback');
    ForcedReset = require('./forced-reset');
    Queryable = require('./queryable');

    /**
     * Adds sorting support to a Collection. It relies on Queryable
     * mixin to persist sorting query state and add it to url query params
     * on every sync action.
     * @param  {Collection} base superclass
     */
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var Sorted;
        return Sorted = (function(superClass) {
          extend(Sorted, superClass);

          function Sorted() {
            return Sorted.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(Sorted.prototype, 'Sorted');

          Sorted.prototype.DEFAULTS = _.extend({}, Sorted.prototype.DEFAULTS, {
            order: 'desc',
            sort_by: void 0
          });

          Sorted.prototype.initialize = function() {
            helper.assertCollection(this);
            return Sorted.__super__.initialize.apply(this, arguments);
          };

          Sorted.prototype.fetch = function() {
            this.reset();
            return Sorted.__super__.fetch.apply(this, arguments);
          };

          return Sorted;

        })(Queryable(ForcedReset(SafeSyncCallback(superclass))));
      });
    };
  });

}).call(this);

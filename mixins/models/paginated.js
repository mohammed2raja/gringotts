(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var StatefulUrlParams, SyncKey, helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');
    StatefulUrlParams = require('./stateful-url-params');
    SyncKey = require('./sync-key');

    /**
     * Adds pagination support to a Collection. It relies on StatefulUrlParams
     * mixin to persist pagination state and add to url query params on every
     * sync action.
     * @param  {Collection} base superclass
     */
    return function(base) {
      var Paginated;
      return Paginated = (function(superClass) {
        extend(Paginated, superClass);

        function Paginated() {
          return Paginated.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(Paginated.prototype, 'Paginated');

        Paginated.prototype.DEFAULTS = _.extend({}, Paginated.prototype.DEFAULTS, {
          page: 1,
          per_page: 30
        });


        /**
         * Sets the pagination mode for collection.
         * @type {Boolean} True if infitine, false otherwise
         */

        Paginated.prototype.infinite = false;

        Paginated.prototype.initialize = function() {
          helper.assertCollection(this);
          Paginated.__super__.initialize.apply(this, arguments);
          return this.on('remove', function() {
            return this.count = Math.max(0, (this.count || 1) - 1);
          });
        };

        Paginated.prototype.parse = function(resp) {
          var result;
          result = Paginated.__super__.parse.apply(this, arguments);
          if (this.infinite) {
            this.nextPageId = resp.next_page_id;
          }
          return result;
        };

        return Paginated;

      })(utils.mix(base)["with"](StatefulUrlParams, SyncKey));
    };
  });

}).call(this);

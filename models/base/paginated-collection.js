(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Collection, PaginatedCollection;
    Collection = require('./collection');

    /**
     * The Collection from which to extend for pagination needs.
     */
    return PaginatedCollection = (function(superClass) {
      extend(PaginatedCollection, superClass);

      function PaginatedCollection() {
        return PaginatedCollection.__super__.constructor.apply(this, arguments);
      }

      PaginatedCollection.prototype.DEFAULTS = _.extend({}, PaginatedCollection.prototype.DEFAULTS, {
        page: 1,
        per_page: 30
      });


      /**
       * Sets the pagination mode for collection.
       * @type {Boolean} True if infitine, false otherwise
       */

      PaginatedCollection.prototype.infinite = false;

      PaginatedCollection.prototype.parse = function(resp) {
        if (this.infinite) {
          this.nextPageId = resp.next_page_id;
        }
        return PaginatedCollection.__super__.parse.apply(this, arguments);
      };

      return PaginatedCollection;

    })(Collection);
  });

}).call(this);

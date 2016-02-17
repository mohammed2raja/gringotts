(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Collection, PaginatedCollection, utils;
    Collection = require('./collection');
    utils = require('../../lib/utils');

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

      return PaginatedCollection;

    })(Collection);
  });

}).call(this);

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');

    /**
     * A utility mixin for a View or a CollectionView. It helps to pass routing
     * parameters down the view hierarchy. Also adds helper methods to get current
     * browser query state (usually it's received from a Collection or a Model
     * with Queryable mixin applied) or to redirect browser to current
     * route with updated query state.
     * The routeQueryable is expected to be a Queryable or it's proxy
     * with getQuery() method.
     * @param  {View|CollectionView} superclass
     */
    return function(superclass) {
      var Routing;
      return Routing = (function(superClass) {
        var ref;

        extend(Routing, superClass);

        function Routing() {
          return Routing.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(Routing.prototype, 'Routing');

        Routing.prototype.ROUTING_OPTIONS = ['routeName', 'routeParams', 'routeQueryable'];

        Routing.prototype.optionNames = (ref = Routing.prototype.optionNames) != null ? ref.concat(Routing.prototype.ROUTING_OPTIONS) : void 0;

        Routing.prototype.initialize = function() {
          var ref1, ref2;
          helper.assertViewOrCollectionView(this);
          Routing.__super__.initialize.apply(this, arguments);
          if (!this.routeQueryable) {
            this.routeQueryable = (ref1 = this.collection || this.model) != null ? typeof ref1.proxyQueryable === "function" ? ref1.proxyQueryable() : void 0 : void 0;
          }
          if ((ref2 = this.routeQueryable) != null ? ref2.trigger : void 0) {
            return this.listenTo(this.routeQueryable, 'queryChange', function(info) {
              if (!this.muteQueryChangeEvent) {
                return this.onBrowserQueryChange(info.query, info.diff);
              } else {
                return delete this.muteQueryChangeEvent;
              }
            });
          }
        };


        /**
         * Overrides Chaplin.CollectionView method to init sub items with
         * routing properties
         * @return {View}
         */

        Routing.prototype.initItemView = function() {
          return _.extend(Routing.__super__.initItemView.apply(this, arguments), this.routeOpts());
        };

        Routing.prototype.getTemplateData = function() {
          return _.extend(Routing.__super__.getTemplateData.apply(this, arguments), {
            routeName: this.routeName,
            routeParams: this.routeParams
          });
        };


        /**
         * A hash of current routing options.
         * @return {Object}
         */

        Routing.prototype.routeOpts = function() {
          return _.reduce(this.ROUTING_OPTIONS, (function(_this) {
            return function(result, key) {
              result[key] = _this[key];
              return result;
            };
          })(this), {});
        };


        /**
         * A hash of current routing options extended with other has.
         * @return {Object}
         */

        Routing.prototype.routeOptsWith = function(hash) {
          return _.extend(this.routeOpts(), hash);
        };


        /**
         * Returns current query of the browser query relevant to the routeName.
         * @return {Object}
         */

        Routing.prototype.getBrowserQuery = function() {
          if (!this.routeQueryable) {
            throw new Error("Can't get query since @routeQueryable isn't set.");
          }
          return this.routeQueryable.getQuery({}, {
            inclDefaults: true,
            usePrefix: false
          });
        };


        /**
         * Redirect to current route with new query params.
         * @param {Object} query to build URL query params with.
         */

        Routing.prototype.setBrowserQuery = function(query, options) {
          if (query == null) {
            query = {};
          }
          if (!this.routeQueryable) {
            throw new Error("Can't set browser query since @routeQueryable isn't set.");
          }
          if (!this.routeName) {
            throw new Error("Can't set browser query since @routeName isn't set.");
          }
          this.muteQueryChangeEvent = true;
          return utils.redirectTo(this.routeName, this.routeParams, _.extend({}, options, {
            query: this.routeQueryable.getQuery(query)
          }));
        };


        /**
         * Override this method to add your logic upon browser query change.
         * @param  {Object} query   current browser query from URL query params.
         * @param  {Object} diff    difference object from previous query.
         */

        Routing.prototype.onBrowserQueryChange = function(query, diff) {};

        Routing.prototype.dispose = function() {
          this.ROUTING_OPTIONS.forEach((function(_this) {
            return function(key) {
              return delete _this[key];
            };
          })(this));
          return Routing.__super__.dispose.apply(this, arguments);
        };

        return Routing;

      })(superclass);
    };
  });

}).call(this);

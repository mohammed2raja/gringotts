(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, utils;
    utils = require('lib/utils');
    helper = require('../helper');

    /**
     * A utility mixin for a View or a CollectionView. It helps to pass routing
     * parameters down the view hierarchy. Also adds helper methods to get current
     * browser query state (usually it's received from a Collection or a Model
     * with StatefulUrlParams mixin applied) or to redirect browser to current
     * route with updated query state.
     * The routeState is expected to be a StatefulUrlParams or it's proxy
     * with getState() method.
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

        Routing.prototype.ROUTING_OPTIONS = ['routeName', 'routeParams', 'routeState'];

        Routing.prototype.optionNames = (ref = Routing.prototype.optionNames) != null ? ref.concat(Routing.prototype.ROUTING_OPTIONS) : void 0;

        Routing.prototype.initialize = function() {
          var ref1;
          helper.assertViewOrCollectionView(this);
          Routing.__super__.initialize.apply(this, arguments);
          if (!this.routeState) {
            this.routeState = (ref1 = this.collection || this.model) != null ? typeof ref1.proxyState === "function" ? ref1.proxyState() : void 0 : void 0;
          }
          if (this.routeState && this.routeState.trigger) {
            return this.listenTo(this.routeState, 'stateChange', function(state) {
              if (!this.muteStateChangeEvent) {
                return this.onBrowserStateChange(state);
              } else {
                return delete this.muteStateChangeEvent;
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
          var view;
          view = Routing.__super__.initItemView.apply(this, arguments);
          this.ROUTING_OPTIONS.forEach((function(_this) {
            return function(key) {
              return view[key] = _this[key];
            };
          })(this));
          return view;
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
         * Returns current state of the browser query relevant to the routeName.
         * @return {Object}
         */

        Routing.prototype.getBrowserState = function() {
          if (!this.routeState) {
            throw new Error("Can't get state since @routeState isn't set.");
          }
          return this.routeState.getState({}, {
            inclDefaults: true
          });
        };


        /**
         * Redirect to current route with new query params.
         * @param {Object} state to build URL query params with.
         */

        Routing.prototype.setBrowserState = function(state) {
          if (state == null) {
            state = {};
          }
          if (!this.routeState) {
            throw new Error("Can't set browser state since @routeState isn't set.");
          }
          if (!this.routeName) {
            throw new Error("Can't set browser state since @routeName isn't set.");
          }
          this.muteStateChangeEvent = true;
          return utils.redirectTo(this.routeName, this.routeParams, {
            query: this.routeState.getState(state)
          });
        };


        /**
         * Override this method to add your logic upon browser state change.
         * @param  {Object} state current browser state from URL query params.
         */

        Routing.prototype.onBrowserStateChange = function(state) {};

        Routing.prototype.dispose = function() {
          var ref1;
          this.ROUTING_OPTIONS.forEach((function(_this) {
            return function(key) {
              return delete _this[key];
            };
          })(this));
          if ((ref1 = this.routeState) != null) {
            if (typeof ref1.dispose === "function") {
              ref1.dispose();
            }
          }
          return Routing.__super__.dispose.apply(this, arguments);
        };

        return Routing;

      })(superclass);
    };
  });

}).call(this);

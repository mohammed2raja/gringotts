(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Backbone, helper, utils;
    Backbone = require('backbone');
    utils = require('lib/utils');
    helper = require('../helper');

    /**
     * Adds a capability of scoping a Collection or Model url with custom query
     * params for every sync request.
     * Adds a persistent state storage to keep track of all parameters that
     * has to be added to the url.
     * Adds support of default state parameter values and translation of client
     * param keys to server onces. Also with ability to ignore some of the
     * keys.
     * If there are multiple instances of a Collection or a Model assined to
     * views on the same screen, please use prefix property to distringuish
     * state params before passing it to Chaplin routing system.
     * @param  {Model|Collection} superclass
     */
    return function(superclass) {
      var StatefulUrlParams;
      return StatefulUrlParams = (function(superClass) {
        var StateProxy;

        extend(StatefulUrlParams, superClass);

        function StatefulUrlParams() {
          return StatefulUrlParams.__super__.constructor.apply(this, arguments);
        }


        /**
         * Default query params hash for this collection.
         * Override when necessary.
         */

        StatefulUrlParams.prototype.DEFAULTS = {};


        /**
         * Used to map local param names to queryparam server attrs
         * Override when necessary.
         */

        StatefulUrlParams.prototype.DEFAULTS_SERVER_MAP = {};


        /**
         * State storage for the params.
         * @type {Object}
         */

        StatefulUrlParams.prototype.state = null;


        /**
         * Custom string keyword to scope input state keys. Useful if there is
         * a case of using two or more instances of a Model assigned to views
         * on the browser page.
         * @type {String}
         */

        StatefulUrlParams.prototype.prefix = null;


        /**
         * List of state keys to ignore while building url for fetching items.
         * @type {Array}
         */

        StatefulUrlParams.prototype.ignoreKeys = null;

        StatefulUrlParams.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          if (typeof this.url !== 'function') {
            throw new Error('Please use urlRoot instead of url as a URL property for syncing.');
          }
          StatefulUrlParams.__super__.initialize.apply(this, arguments);
          return this.state = {};
        };


        /**
         * Generates a state hash from the current state and given overrides.
         * @param  {Object} overrides={} Optional overrides
         * @param  {Object} opts={}      inclDefaults - adds default state
         *                               values into result, it is false by default.
         *                               usePrefix - adds prefix string into state
         *                               property key, it is true by default.
         * @return {Object}              Combined state
         */

        StatefulUrlParams.prototype.getState = function(overrides, opts) {
          var state;
          if (overrides == null) {
            overrides = {};
          }
          if (opts == null) {
            opts = {};
          }
          state = _.extend({}, this.DEFAULTS, this.state, overrides);
          if (!_.isEmpty(_.intersection(_.keys(state), _.keys(this.DEFAULTS_SERVER_MAP)))) {
            throw new Error('Pass in only local state properties.');
          }
          state = this.stripEmptyOrDefault(state, opts);
          if (this.prefix && (!_.isBoolean(opts.usePrefix) || opts.usePrefix)) {
            state = _(state).mapKeys((function(_this) {
              return function(value, key) {
                return _this.prefix + "_" + key;
              };
            })(this)).extend(this.alienState).value();
          }
          return state;
        };


        /**
         * Sets current state.
         * @param {Object} state - Queryparams for the new state
         */

        StatefulUrlParams.prototype.setState = function(state) {
          var ref;
          if (state == null) {
            state = {};
          }
          this.state = this.stripEmptyOrDefault(this.unprefixKeys(state));
          this.trigger('stateChange', this.state, this);
          return (ref = this.fetch({
            reset: true
          })) != null ? ref.fail((function(_this) {
            return function() {
              return _this.reset();
            };
          })(this)) : void 0;
        };


        /**
         * Strips the state from all undefined or default values
         */

        StatefulUrlParams.prototype.stripEmptyOrDefault = function(state, opts) {
          if (opts == null) {
            opts = {};
          }
          return state = _.omit(state, (function(_this) {
            return function(value, key) {
              return value === void 0 || (_.isEqual(_this.DEFAULTS[key], value) && !opts.inclDefaults);
            };
          })(this));
        };


        /**
         * Saves all alien values (without prefixes) into a separete hash
         * (to return on getState()). Renames prefixed keys into normal form.
         * @return {Object}
         */

        StatefulUrlParams.prototype.unprefixKeys = function(state) {
          if (!this.prefix) {
            return state;
          }
          this.alienState = {};
          return state = _(state).omit((function(_this) {
            return function(value, key) {
              var alien;
              if (alien = key.indexOf(_this.prefix) < 0) {
                _this.alienState[key] = value;
              }
              return alien;
            };
          })(this)).mapKeys((function(_this) {
            return function(value, key) {
              return key.replace(_this.prefix + "_", '');
            };
          })(this)).value();
        };


        /**
         * Incorporate the collection state.
         * @param   {String} urlRoot optional urlRoot to calculate url, if it's
         *                           not set this.urlRoot will be used.
         * @returns {String}
         */

        StatefulUrlParams.prototype.url = function(urlRoot, state) {
          var base, query;
          if (urlRoot == null) {
            urlRoot = this.urlRoot;
          }
          if (!urlRoot) {
            throw new Error('Please define a urlRoot when implementing a collection');
          }
          if (!state) {
            state = this.getState({}, {
              inclDefaults: true,
              usePrefix: false
            });
          }
          state = _.mapKeys(_.omit(state, this.ignoreKeys), (function(_this) {
            return function(value, key) {
              return _.invert(_this.DEFAULTS_SERVER_MAP)[key] || key;
            };
          })(this));
          base = _.isFunction(urlRoot) ? urlRoot.apply(this) : urlRoot;
          query = utils.querystring.stringify(state);
          return this.urlWithQuery(base, query);
        };


        /**
         * Combines URL base with query params.
         * @param  {String|Array|Object} base Base part of the URL, it supported
         *                                    in form of Array (of URLs), Object
         *                                    (Hash of URLs) or String (just URL).
         * @param  {String} query             Query params string
         * @return {String|Array|Object}      A new instance of amended base.
         */

        StatefulUrlParams.prototype.urlWithQuery = function(base, query) {
          var bases, firstKey, keys, url;
          url = base;
          if (query) {
            if (_.isString(base)) {
              url = base + "?" + query;
            } else if (_.isArray(base) && base.length > 0) {
              bases = _.clone(base);
              bases[0] = (_.first(bases)) + "?" + query;
              url = bases;
            } else if (_.isObject(base) && (keys = _.keys(base))) {
              bases = _.clone(base);
              firstKey = _.first(keys);
              bases[firstKey] = bases[firstKey] + "?" + query;
              url = bases;
            }
          }
          return url;
        };

        StateProxy = (function() {
          _.extend(StateProxy.prototype, Backbone.Events);

          function StateProxy(collection) {
            this.getState = _.bind(collection.getState, collection);
            this.listenTo(collection, 'stateChange', (function(_this) {
              return function(state) {
                return _this.trigger('stateChange', state, _this);
              };
            })(this));
          }

          StateProxy.prototype.dispose = function() {
            delete this.getState;
            this.stopListening();
            return this.off();
          };

          return StateProxy;

        })();


        /**
         * A simple proxy object with only getState method to pass around.
         * @return {Object}
         */

        StatefulUrlParams.prototype.proxyState = function() {
          return new StateProxy(this);
        };

        return StatefulUrlParams;

      })(superclass);
    };
  });

}).call(this);

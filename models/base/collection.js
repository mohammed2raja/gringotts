(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Abortable, ActiveSyncMachine, Chaplin, Collection, Model, SafeSyncCallback, ServiceErrorCallback, utils;
    Chaplin = require('chaplin');
    utils = require('../../lib/utils');
    ActiveSyncMachine = require('../../mixins/active-sync-machine');
    Abortable = require('../../mixins/abortable');
    SafeSyncCallback = require('../../mixins/safe-sync-callback');
    ServiceErrorCallback = require('../../mixins/service-error-callback');
    Model = require('./model');
    return Collection = (function(superClass) {
      extend(Collection, superClass);

      function Collection() {
        return Collection.__super__.constructor.apply(this, arguments);
      }

      Collection.prototype.model = Model;


      /**
       * State of the data with relation to the server.
       * @type {Object}
       */

      Collection.prototype.state = null;


      /**
       * Custom string keyword to scope input state keys. Useful if there is
       * a case of using two or more instances of CollectionView on one page.
       * @type {String}
       */

      Collection.prototype.prefix = null;


      /**
       * Default queryparam object for this collection.
       * Must contain all possible querynewState.
       * Override when necessary.
       */

      Collection.prototype.DEFAULTS = {
        order: 'desc',
        q: void 0,
        sort_by: void 0
      };


      /**
       * Used to map local property names to queryparam server attrs
       * Override when necessary.
       */

      Collection.prototype.DEFAULTS_SERVER_MAP = {};

      Collection.prototype.initialize = function() {
        if (typeof this.url !== 'function') {
          throw new Error('Please use urlRoot instead of url as a collection property');
        }
        Collection.__super__.initialize.apply(this, arguments);
        this.state = {};
        return this.on('remove', function() {
          return this.count = Math.max(0, (this.count || 1) - 1);
        });
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

      Collection.prototype.getState = function(overrides, opts) {
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

      Collection.prototype.setState = function(state) {
        var ref;
        if (state == null) {
          state = {};
        }
        this.state = this.stripEmptyOrDefault(this.unprefixKeys(state));
        this.trigger('stateChange', this, this.state);
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

      Collection.prototype.stripEmptyOrDefault = function(state, opts) {
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

      Collection.prototype.unprefixKeys = function(state) {
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

      Collection.prototype.url = function(urlRoot, state) {
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
        state = _.mapKeys(state, (function(_this) {
          return function(value, key) {
            return _.invert(_this.DEFAULTS_SERVER_MAP)[key] || key;
          };
        })(this));
        query = utils.querystring.stringify(state);
        base = _.isFunction(urlRoot) ? urlRoot.apply(this) : urlRoot;
        if (query) {
          return base + "?" + query;
        } else {
          return "" + base;
        }
      };

      Collection.prototype.parse = function(resp) {
        if (this.syncKey) {
          this.count = parseInt(resp.count);
          return resp[this.syncKey];
        } else {
          return resp;
        }
      };

      return Collection;

    })(utils.mix(Chaplin.Collection)["with"](ActiveSyncMachine, Abortable, SafeSyncCallback, ServiceErrorCallback));
  });

}).call(this);

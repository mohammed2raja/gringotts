(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, Collection, Model, activeSyncMachine, advice, overrideXHR, safeSyncCallback, serviceErrorCallback, utils;
    Chaplin = require('chaplin');
    utils = require('../../lib/utils');
    advice = require('../../mixins/advice');
    activeSyncMachine = require('../../mixins/active-sync-machine');
    overrideXHR = require('../../mixins/override-xhr');
    safeSyncCallback = require('../../mixins/safe-sync-callback');
    serviceErrorCallback = require('../../mixins/service-error-callback');
    Model = require('./model');
    return Collection = (function(superClass) {
      extend(Collection, superClass);

      function Collection() {
        return Collection.__super__.constructor.apply(this, arguments);
      }

      _.extend(Collection.prototype, Chaplin.SyncMachine);

      _.extend(Collection.prototype, activeSyncMachine);

      _.extend(Collection.prototype, safeSyncCallback);

      _.extend(Collection.prototype, serviceErrorCallback);

      _.extend(Collection.prototype, overrideXHR);

      advice.call(Collection.prototype);

      Collection.prototype.model = Model;

      Collection.prototype.initialize = function() {
        Collection.__super__.initialize.apply(this, arguments);
        this.state = {};
        if (typeof this.url !== 'function') {
          throw new Error('Please use urlRoot instead of url as a collection property');
        }
        this.activateSyncMachine();
        this.on('dispose', function(model) {
          if (model instanceof Chaplin.Model && !this.disposed) {
            return this.remove(model);
          }
        });
        return this.on('remove', function() {
          return this.count = Math.max(0, (this.count || 1) - 1);
        });
      };


      /**
       * State of the data with relation to the server.
       * @type {Object}
       */

      Collection.prototype.state = null;


      /**
        * Default queryparam object for this collection.
        * Must contain all possible querynewState.
        * Override when necessary.
       */

      Collection.prototype.DEFAULTS = {
        order: 'desc',
        q: void 0,
        sort_by: void 0,
        page: 1
      };


      /**
        * Used to map local property names to queryparam server attrs
        * Override when necessary.
       */

      Collection.prototype.DEFAULTS_SERVER_MAP = {};


      /**
       * Return whether or not the prop/val is a default one.
       * @param  {string}  prop - local formatted prop name
       * @param  val  - Value of the property
       * @return {Boolean}
       */

      Collection.prototype._isDefault = function(key, val) {
        var serverKey;
        serverKey = _.invert(this.DEFAULTS_SERVER_MAP)[key] || key;
        return _.isEqual(this.DEFAULTS[serverKey], val);
      };

      Collection.prototype._stripState = function(state, withDefaults) {
        if (withDefaults == null) {
          withDefaults = false;
        }
        return _.omit(state, function(v, k) {
          return v === void 0 || (this._isDefault(k, v) && !withDefaults);
        }, this);
      };


      /**
        * Generate a state from the given and current states.
        * Whenever we getState we need to pass in all non-default
        * prop/values that we want.
        * @prop {object} overrides - Optional local-formatted state to include or
        *                            override.
        * @prop {boolean} withDefaults
        * @returns {object} state
       */

      Collection.prototype.getState = function(overrides, withDefaults) {
        var defaults, state;
        if (overrides == null) {
          overrides = {};
        }
        if (withDefaults == null) {
          withDefaults = false;
        }
        defaults = _.mapKeys(this.DEFAULTS, function(value, key) {
          return this.DEFAULTS_SERVER_MAP[key] || key;
        }, this);
        state = _.extend({}, defaults, this.state, overrides);
        if (!_.isEmpty(_.intersection(_.keys(state), _.keys(this.DEFAULTS_SERVER_MAP)))) {
          throw new Error('Pass in only local state properties.');
        }
        return this._stripState(state, withDefaults);
      };


      /**
        * @param {object} state - Queryparams for the new state
       */

      Collection.prototype.setState = function(state) {
        if (state == null) {
          state = {};
        }
        this.state = this._stripState(state);
        this.trigger('stateChange', this, this.state);
        return this.fetch({
          reset: true
        });
      };

      Collection.prototype.sync = function() {
        this.serviceErrorCallback.apply(this, arguments);
        this.safeSyncCallback.apply(this, arguments);
        return Collection.__super__.sync.apply(this, arguments);
      };

      Collection.prototype.fetch = function() {
        return this.overrideXHR(Collection.__super__.fetch.apply(this, arguments));
      };


      /**
       * Incorporate the collection state.
       * @param   {string} urlRoot optional urlRoot to calculate url, if it's
       *                           not set this.urlRoot will be used.
       * @returns {string}
       */

      Collection.prototype.url = function(urlRoot, state) {
        var base, query, queryState;
        if (urlRoot == null) {
          urlRoot = this.urlRoot;
        }
        if (state == null) {
          state = this.getState({}, true);
        }
        if (!urlRoot) {
          throw new Error('Please define a urlRoot when implementing a collection');
        }
        queryState = _.mapKeys(state, function(value, key) {
          return _.invert(this.DEFAULTS_SERVER_MAP)[key] || key;
        }, this);
        query = utils.querystring.stringify(queryState);
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

    })(Chaplin.Collection);
  });

}).call(this);

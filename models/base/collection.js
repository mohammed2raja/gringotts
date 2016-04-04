(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ActiveSyncMachine, Chaplin, Collection, Model, OverrideXHR, SafeSyncCallback, ServiceErrorCallback, utils;
    Chaplin = require('chaplin');
    utils = require('../../lib/utils');
    ActiveSyncMachine = require('../../mixins/active-sync-machine');
    OverrideXHR = require('../../mixins/override-xhr');
    SafeSyncCallback = require('../../mixins/safe-sync-callback');
    ServiceErrorCallback = require('../../mixins/service-error-callback');
    Model = require('./model');
    return Collection = (function(superClass) {
      extend(Collection, superClass);

      function Collection() {
        return Collection.__super__.constructor.apply(this, arguments);
      }

      Collection.prototype.model = Model;

      Collection.prototype.initialize = function() {
        Collection.__super__.initialize.apply(this, arguments);
        this.state = {};
        if (typeof this.url !== 'function') {
          throw new Error('Please use urlRoot instead of url as a collection property');
        }
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
       * Strips the state from all undefined or default values
       * @param  {Object} state
       * @param  {Boolean} withDefaults=false whether defaults should be removed
       */

      Collection.prototype._stripState = function(state, withDefaults) {
        if (withDefaults == null) {
          withDefaults = false;
        }
        return _.omit(state, (function(_this) {
          return function(value, key) {
            return value === void 0 || _.isEqual(_this.DEFAULTS[key], value) && !withDefaults;
          };
        })(this));
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
        var state;
        if (overrides == null) {
          overrides = {};
        }
        if (withDefaults == null) {
          withDefaults = false;
        }
        state = _.extend({}, this.DEFAULTS, this.state, overrides);
        if (!_.isEmpty(_.intersection(_.keys(state), _.keys(this.DEFAULTS_SERVER_MAP)))) {
          throw new Error('Pass in only local state properties.');
        }
        return this._stripState(state, withDefaults);
      };


      /**
        * @param {object} state - Queryparams for the new state
       */

      Collection.prototype.setState = function(state) {
        var ref;
        if (state == null) {
          state = {};
        }
        this.state = this._stripState(state);
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
        queryState = _.mapKeys(state, (function(_this) {
          return function(value, key) {
            return _.invert(_this.DEFAULTS_SERVER_MAP)[key] || key;
          };
        })(this));
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

    })(utils.mix(Chaplin.Collection)["with"](ActiveSyncMachine, OverrideXHR, SafeSyncCallback, ServiceErrorCallback));
  });

}).call(this);

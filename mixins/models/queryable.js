(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Backbone, helper, utils;
    Backbone = require('backbone');
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');

    /**
     * Adds a capability of scoping a Collection or Model url with custom query
     * params for every sync request.
     * Adds a persistent query state storage to keep track of all parameters that
     * has to be added to the url.
     * Adds support of default query state parameter values and translation
     * of client param keys to server onces. Also with ability to ignore some
     * of the keys.
     * If there are multiple instances of a Collection or a Model assined to
     * views on the same screen, please use prefix property to distringuish
     * query state params before passing it to Chaplin routing system.
     * @param  {Model|Collection} superclass
     */
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var Queryable;
        return Queryable = (function(superClass) {
          var QueryableProxy;

          extend(Queryable, superClass);

          function Queryable() {
            return Queryable.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(Queryable.prototype, 'Queryable');


          /**
           * Default query params hash for this collection.
           * Override when necessary.
           */

          Queryable.prototype.DEFAULTS = {};


          /**
           * Used to map local param names to queryparam server attrs
           * Override when necessary.
           */

          Queryable.prototype.DEFAULTS_SERVER_MAP = {};


          /**
           * Query state storage for the params.
           * @type {Object}
           */

          Queryable.prototype.query = null;


          /**
           * Custom string keyword to scope input query keys. Useful if there is
           * a case of using two or more instances of a Model assigned to views
           * on the browser page.
           * @type {String}
           */

          Queryable.prototype.prefix = null;


          /**
           * List of query keys to ignore while building url for fetching items.
           * @type {Array}
           */

          Queryable.prototype.ignoreKeys = null;

          Queryable.prototype.initialize = function() {
            helper.assertModelOrCollection(this);
            if (typeof this.url !== 'function') {
              throw new Error('Please use urlRoot instead of url as a URL property for syncing.');
            }
            Queryable.__super__.initialize.apply(this, arguments);
            return this.query = {};
          };


          /**
           * Generates a query hash from the current query and given overrides.
           * @param  {Object} opts={}      inclDefaults - adds default query
           *                               values into result, it is false by default.
           *                               usePrefix - adds prefix string into query
           *                               property key, it is true by default.
           *                               overrides - optional state overrides.
           * @return {Object}              Combined query
           */

          Queryable.prototype.getQuery = function(opts) {
            var query;
            if (opts == null) {
              opts = {};
            }
            query = _.extend({}, this.DEFAULTS, this.query, opts.overrides);
            if (!_.isEmpty(_.intersection(_.keys(query), _.keys(this.DEFAULTS_SERVER_MAP)))) {
              throw new Error('Pass in only local query properties.');
            }
            query = this.stripEmptyOrDefault(query, opts);
            if (this.prefix && (!_.isBoolean(opts.usePrefix) || opts.usePrefix)) {
              query = _(query).mapKeys((function(_this) {
                return function(value, key) {
                  return _this.prefix + "_" + key;
                };
              })(this)).extend(this.alienQuery).value();
            }
            return query;
          };


          /**
           * Sets current query.
           * @param {String|Object} query  Query params for the new query
           * @return {Array}               Array of changed value keys.
           */

          Queryable.prototype.setQuery = function(query) {
            if (_.isString(query)) {
              return this.setQueryString(query);
            } else {
              return this.setQueryHash(query);
            }
          };


          /**
           * Sets current query in string format.
           * @param {String}  query   Queryparams in string format "a=b&c=d"
           * @return {Array}          Array of changed value keys.
           */

          Queryable.prototype.setQueryString = function(query) {
            if (query == null) {
              query = '';
            }
            return this.setQueryHash(utils.querystring.parse(query));
          };


          /**
           * Sets current query in object format.
           * @param {Object}  query   Query params in object format {a: 'b', c: 'd'}
           * @return {Array}          Array of changed value keys.
           */

          Queryable.prototype.setQueryHash = function(query) {
            var diff, newQuery;
            if (query == null) {
              query = {};
            }
            if (!_.isObject(query)) {
              throw new Error('New query should be String or Object');
            }
            newQuery = this.stripEmptyOrDefault(this.unprefixKeys(query));
            diff = this.queryDiff(this.query, newQuery);
            if (diff.length) {
              this.query = newQuery;
              this.trigger('queryChange', {
                query: this.query,
                diff: diff
              }, this);
              return diff;
            } else {
              return null;
            }
          };


          /**
           * Applies query params and fetch new data if params changed
           * (and not part of ignored list) or if this is a first time fetching.
           * @param  {String|Object} query    Query params for the new query.
           * @param  {Object}        options  Set of options for fetch method.
           * @return {$.Deferred}
           */

          Queryable.prototype.fetchWithQuery = function(query, options) {
            var changedKeys, queryChanged;
            changedKeys = this.setQuery(query);
            queryChanged = changedKeys && (!this.ignoreKeys || !_.all(changedKeys, (function(_this) {
              return function(key) {
                return _this.ignoreKeys.indexOf(key) >= 0;
              };
            })(this)));
            if (queryChanged || this.isUnsynced()) {
              return this.fetch(options);
            } else {
              return $.Deferred().resolve();
            }
          };


          /**
           * Strips the query from all undefined or default values
           */

          Queryable.prototype.stripEmptyOrDefault = function(query, opts) {
            if (opts == null) {
              opts = {};
            }
            return query = _.omit(query, (function(_this) {
              return function(value, key) {
                return value === void 0 || (_.isEqual(_this.DEFAULTS[key], value) && !opts.inclDefaults);
              };
            })(this));
          };


          /**
           * Saves all alien values (without prefixes) into a separete hash
           * (to return on getQuery()). Renames prefixed keys into normal form.
           * @return {Object}
           */

          Queryable.prototype.unprefixKeys = function(query) {
            if (!this.prefix) {
              return query;
            }
            this.alienQuery = {};
            return query = _(query).omit((function(_this) {
              return function(value, key) {
                var alien;
                if (alien = key.indexOf(_this.prefix) < 0) {
                  _this.alienQuery[key] = value;
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
           * Returns URL with collection query params.
           * @returns {String}
           */

          Queryable.prototype.url = function() {
            var base, query, querystring;
            base = this.urlRoot || Queryable.__super__.url;
            if (!base) {
              throw new Error('Please define url or urlRoot when implementing a queryable model or collection');
            }
            base = _.isFunction(base) ? base.apply(this) : base;
            query = this.getQuery({
              inclDefaults: true,
              usePrefix: false
            });
            query = _.mapKeys(_.omit(query, this.ignoreKeys), (function(_this) {
              return function(value, key) {
                return _.invert(_this.DEFAULTS_SERVER_MAP)[key] || key;
              };
            })(this));
            querystring = utils.querystring.stringify(query);
            return this.urlWithQuery(base, querystring);
          };


          /**
           * Combines URL base with query params.
           * @param  {String|Array|Object} base Base part of the URL, it supported
           *                                    in form of Array (of URLs), Object
           *                                    (Hash of URLs) or String (just URL).
           * @param  {String} querystring       Query params string
           * @return {String|Array|Object}      A new instance of amended base.
           */

          Queryable.prototype.urlWithQuery = function(base, querystring) {
            var bases, firstKey, keys, url;
            url = base;
            if (querystring) {
              if (_.isString(base)) {
                url = base + "?" + querystring;
              } else if (_.isArray(base) && base.length > 0) {
                bases = _.clone(base);
                bases[0] = (_.first(bases)) + "?" + querystring;
                url = bases;
              } else if (_.isObject(base) && (keys = _.keys(base))) {
                bases = _.clone(base);
                firstKey = _.first(keys);
                bases[firstKey] = bases[firstKey] + "?" + querystring;
                url = bases;
              }
            }
            return url;
          };


          /**
           * Returns difference between two objects.
           * @return {Array}  Array of different value keys.
           */

          Queryable.prototype.queryDiff = function(queryA, queryB) {
            var diffA, diffB, difference;
            diffA = _.keys(_.pick(queryA, function(v, k) {
              return !_.isEqual(queryB[k], v);
            }));
            diffB = _.keys(_.pick(queryB, function(v, k) {
              return !_.isEqual(queryA[k], v);
            }));
            return difference = _.union(diffA, diffB);
          };

          QueryableProxy = (function() {
            _.extend(QueryableProxy.prototype, Backbone.Events);

            QueryableProxy.prototype.disposed = false;

            function QueryableProxy(queryable) {
              this.getQuery = _.bind(queryable.getQuery, queryable);
              this.listenTo(queryable, 'queryChange', function(info) {
                return this.trigger('queryChange', info, this);
              });
              this.listenTo(queryable, 'dispose', function() {
                return this.dispose();
              });
            }

            QueryableProxy.prototype.dispose = function() {
              delete this.getQuery;
              this.stopListening();
              this.off();
              this.disposed = true;
              return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
            };

            return QueryableProxy;

          })();


          /**
           * A simple proxy object with only getQuery method to pass around.
           * @return {Object}
           */

          Queryable.prototype.proxyQueryable = function() {
            return new QueryableProxy(this);
          };

          return Queryable;

        })(superclass);
      });
    };
  });

}).call(this);

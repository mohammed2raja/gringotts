(function() {
  define(function(require, exports) {
    var advice, scopedUrl, utils, _, _collectParams, _removeDefaults;
    _ = require('underscore');
    advice = require('flight/advice');
    utils = require('../lib/utils');
    _collectParams = function(query) {
      var params;
      params = utils.queryParams.parse(query);
      return _.reduce(this.DEFAULTS, function(memo, value, key) {
        value = params[key] || value;
        if ((+value).toString() === value) {
          value = +value;
        }
        memo[key] = value;
        return memo;
      }, params);
    };
    _removeDefaults = function(params) {
      return _.reduce(params, function(memo, value, key) {
        var comparison, defaultVal;
        defaultVal = this.DEFAULTS[key];
        comparison = _.isArray(value) ? _.uniq(value.concat(defaultVal)) : defaultVal;
        if (!_.isEqual(comparison, value)) {
          memo[key] = value;
        }
        return memo;
      }, {}, this);
    };
    scopedUrl = function(scope) {
      var params;
      params = _.extend({}, this.params, scope);
      if (scope.sort_by) {
        params.order = 'asc';
        if (this.params.sort_by === params.sort_by && this.params.order === 'asc') {
          params.order = 'desc';
        }
      }
      params = _removeDefaults.call(this, params);
      if (this.getPageURL) {
        return this.getPageURL(params);
      } else {
        return utils.reverse(this.syncKey, null, params);
      }
    };
    return exports = function() {
      this.before('sync', function(method, collection, opts) {
        var cleanParams;
        if (method === 'read') {
          this.params = _collectParams.call(this, opts.query);
          cleanParams = _removeDefaults.call(this, this.params);
          return opts.data = opts.data ? _.extend(opts.data, cleanParams) : cleanParams;
        }
      });
      this.scopedUrl = scopedUrl;
      return this;
    };
  });

}).call(this);

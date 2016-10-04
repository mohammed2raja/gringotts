(function() {
  define(function(require) {
    var Backbone, ajax, ajaxForArray, ajaxForHash, backboneAjax;
    Backbone = require('backbone');
    backboneAjax = Backbone.ajax;
    ajaxForArray = function() {
      var options;
      options = _.first(arguments);
      return $.when.apply($, options.url.map(function(url) {
        return backboneAjax(_.merge(_.omit(options, ['url', 'success']), {
          url: url
        }));
      })).done(function() {
        var resp;
        resp = options.url.length > 1 ? _.slice(arguments).map(function(arg) {
          return _.first(arg);
        }) : _.first(arguments);
        return typeof options.success === "function" ? options.success(resp) : void 0;
      });
    };
    ajaxForHash = function() {
      var options, pairs;
      options = _.first(arguments);
      pairs = _.transform(options.url, function(memo, url, key) {
        return memo.push({
          key: key,
          url: url
        });
      }, []);
      return $.when.apply($, pairs.map(function(pair) {
        return backboneAjax(_.merge(_.omit(options, ['url', 'success']), {
          url: pair.url
        }));
      })).done(function() {
        var resp;
        resp = _.slice(arguments).reduce(function(memo, arg, i) {
          memo[pairs[i].key] = _.first(arg);
          return memo;
        }, {});
        return typeof options.success === "function" ? options.success(resp) : void 0;
      });
    };
    ajax = function() {
      var options;
      options = _.first(arguments);
      if (_.isArray(options.url)) {
        return ajaxForArray.apply($, arguments);
      } else if (_.isObject(options.url) && !_.isFunction(options.url)) {
        return ajaxForHash.apply($, arguments);
      } else {
        return backboneAjax.apply($, arguments);
      }
    };

    /**
     * Swiss army knife for ajax. Will create a set of parallel ajax calls for
     * every url that's passed in Array, Hash or String. As soon as all calls are
     * finished the done and options.success callback will be invoked with
     * the results.
     * It's recommended to override Model's parse method to handle multiple
     * response data results.
     * This is useful for models that need to fetch parts of data from different
     * API endpoints.
     * The options.error() will be called as many times as many errors happened
     * during parallel ajax requests execution.
     */
    return {
      backboneAjax: backboneAjax,
      ajaxForArray: ajaxForArray,
      ajaxForHash: ajaxForHash,
      ajax: ajax
    };
  });

}).call(this);

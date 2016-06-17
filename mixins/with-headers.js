(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {

    /**
     * An extensible mixin to intercept Model's syncing operation and adding
     * the required HTTP Headers to the XHR request.
     * @param  {Model|Collection} superclass Any Backbone Model or Collection.
     */
    return function(superclass) {
      var WithHeaders;
      return WithHeaders = (function(superClass) {
        extend(WithHeaders, superClass);

        function WithHeaders() {
          return WithHeaders.__super__.constructor.apply(this, arguments);
        }


        /**
         * A few default headers that are assumed to be added
         * to every ajax request.
         */

        WithHeaders.prototype.HEADERS = {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        };

        WithHeaders.prototype.initialize = function() {
          WithHeaders.__super__.initialize.apply(this, arguments);
          if (!this.HEADERS) {
            throw new Error('HEADERS is required');
          }
        };


        /**
         * Resolves headers and extends Backbone options with updated headers hash
         * before syncing the model.
         * @return {Deferred}   A jquery Deferred object.
         */

        WithHeaders.prototype.sync = function(method, model, options) {
          return this.resolveHeaders(this.HEADERS).then((function(_this) {
            return function(headers) {
              return WithHeaders.__super__.sync.call(_this, method, model, _this.extendWithHeaders(options, headers));
            };
          })(this));
        };


        /**
         * Resolves headers actual value. Since headers maybe be a function then
         * invoke it. Result of the function may be a hash of headers or a jquery
         * Deferred instance. Therefore return a new Deferred for
         * a subsequent chaining.
         * @param  {Object|Function|Deferred} headers Some value to resolve
         *                                            headers from.
         * @return {Object|Deferred}            A hash of headers or a Deferred
         *                                      to chain with.
         */

        WithHeaders.prototype.resolveHeaders = function(headers) {
          var sourceHeaders;
          sourceHeaders = _.isFunction(headers) ? headers.apply(this) : headers;
          return $.when(sourceHeaders);
        };


        /**
         * Extends the Backbone ajax options with headers hash object.
         */

        WithHeaders.prototype.extendWithHeaders = function(options, headers) {
          return _.extend(options, {
            headers: _.extend({}, options.headers, headers)
          });
        };

        return WithHeaders;

      })(superclass);
    };
  });

}).call(this);

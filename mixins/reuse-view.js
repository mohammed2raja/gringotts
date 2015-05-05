(function() {
  define(function(require, exports) {
    var reuseView;
    reuseView = function(params, models, View) {
      var collection, name, opts, query;
      if (params == null) {
        params = {};
      }
      query = params.query;
      collection = this.reuse(params.path, models);
      name = this.viewName || ("" + this.title + "-view");
      collection.reset();
      collection.fetch({
        query: query
      });
      opts = params.opts || {};
      opts.collection = collection;
      return this.reuse(name, View, opts);
    };
    return exports = function() {
      this.reuseView = reuseView;
      return this;
    };
  });

}).call(this);

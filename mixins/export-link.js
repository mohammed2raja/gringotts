(function() {
  define(function(require) {
    return {

      /**
       * Generates a link to export items from the collection bypassing pagination
       * parameters. The mixin should be applied to views that
       * have collection property. Collection should have getState() method.
       * @param  {String} baseUrl - to build export url
       * @return {String}
       */
      exportLink: function(baseUrl) {
        var state;
        state = _.clone(this.collection.getState({}, true));
        delete state.page;
        delete state.per_page;
        return this.collection.url(baseUrl, state);
      }
    };
  });

}).call(this);

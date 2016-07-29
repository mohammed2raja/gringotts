(function() {
  define(function(require) {

    /**
     * A helper class that gets a list of mixins and creates
     * a chain of inheritance.
     */
    var MixinBuilder;
    return MixinBuilder = (function() {

      /**
       * @param  {Type} superclass A target class to mixin into.
       */
      function MixinBuilder(superclass, utils) {
        this.superclass = superclass;
        this.utils = utils;
      }


      /**
       * @param  {Array} ...  A collection of mixins.
       * @return {Type}       A result class with all mixins applied only once.
       */

      MixinBuilder.prototype["with"] = function() {
        return _.reduce(arguments, (function(_this) {
          return function(c, mixin) {
            if (_this.utils.classWithMixin(c, mixin)) {
              return c;
            } else {
              return mixin(c);
            }
          };
        })(this), this.superclass);
      };

      return MixinBuilder;

    })();
  });

}).call(this);

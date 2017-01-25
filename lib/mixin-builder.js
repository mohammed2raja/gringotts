(function() {
  define(function(require) {
    var MixinBuilder, mixinHelper;
    mixinHelper = require('./mixin-helper');

    /**
     * A helper class that gets a list of mixins and creates
     * a chain of inheritance.
     */
    return MixinBuilder = (function() {

      /**
       * @param  {Type} superclass A target class to mixin into.
       */
      function MixinBuilder(superclass) {
        this.superclass = superclass;
      }


      /**
       * @param  {Array} ...  A collection of mixins.
       * @return {Type}       A result class with all mixins applied only once.
       */

      MixinBuilder.prototype["with"] = function() {
        return _.reduce(arguments, function(type, mixin) {
          return mixinHelper.apply(type, mixin);
        }, this.superclass);
      };

      return MixinBuilder;

    })();
  });

}).call(this);

(function() {
  define(function(require) {
    var $, Backbone, Chaplin, MixinBuilder, utils;
    Backbone = require('backbone');
    Chaplin = require('chaplin');
    $ = Backbone.$;

    /**
     * A helper class that gets a list of mixins and creates
     * a chain of inheritance.
     */
    MixinBuilder = (function() {

      /**
       * @param  {Type} superclass A target class to mixin into.
       */
      function MixinBuilder(superclass1) {
        this.superclass = superclass1;
      }


      /**
       * @param  {Array} ...  A collection of mixins.
       * @return {Type}       A result class with all mixins applied.
       */

      MixinBuilder.prototype['with'] = function() {
        return _.reduce(arguments, function(c, mixin) {
          return mixin(c);
        }, this.superclass);
      };

      return MixinBuilder;

    })();
    utils = Chaplin.utils.beget(Chaplin.utils);
    utils.tagBuilder = function(tagName, content, attrs, escape) {
      var tag;
      if (escape == null) {
        escape = true;
      }
      tag = $("<" + tagName + ">");
      if (escape) {
        tag.text(content);
      } else {
        tag.html(content);
      }
      if (attrs) {
        tag.attr(attrs);
      }
      return tag[0].outerHTML;
    };
    utils.parseJSON = function(str) {
      var error, error1, result;
      result = false;
      try {
        result = JSON.parse(str);
      } catch (error1) {
        error = error1;
        if (typeof str === 'undefined') {
          str = 'undefined';
        } else if (str.length === 0) {
          str = 'Empty string';
        }
        if (typeof Raven !== "undefined" && Raven !== null) {
          Raven.captureException(error, {
            tags: {
              str: str
            }
          });
        }
      }
      return result;
    };

    /**
     * Processes hbs helper arguments and extracts funcs and vars.
     * @param  {Object} opts Handlebars helper arguments.
     * @return {Object}      A hash with fn, inverse and args.
     */
    utils.getHandlebarsFuncs = function(opts) {
      var args, lastArg;
      lastArg = _(opts).last();
      args = lastArg.fn ? _.initial(opts) : opts;
      return {
        fn: lastArg.fn,
        inverse: lastArg.inverse,
        args: args
      };
    };

    /**
     * An alias method to MixinBuilder.
     * @param  {Type} superclass A target type to mixin into.
     * @return {Type}            A result type with all mixins applied.
     */
    utils.mix = function(superclass) {
      return new MixinBuilder(superclass);
    };
    return utils;
  });

}).call(this);
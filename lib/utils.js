(function() {
  define(function(require) {
    var Chaplin, MixinBuilder, moment;
    Chaplin = require('chaplin');
    moment = require('moment');
    MixinBuilder = require('./mixin-builder');
    return _.extend({}, Chaplin.utils, {
      tagBuilder: function(tagName, content, attrs, escape) {
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
      },
      parseJSON: function(str) {
        var error, error1, ref, result;
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
          if ((ref = window.Raven) != null) {
            ref.captureException(error, {
              tags: {
                str: str
              }
            });
          }
        }
        return result;
      },
      toBrowserDate: function(date) {
        if (date) {
          return moment(date).format('YYYY-MM-DD');
        }
      },
      toServerDate: function(date) {
        if (date) {
          return moment(date).toISOString();
        }
      },

      /**
       * Processes hbs helper arguments and extracts funcs and vars.
       * @param  {Object} opts Handlebars helper arguments.
       * @return {Object}      A hash with fn, inverse and args.
       */
      getHandlebarsFuncs: function(opts) {
        var args, lastArg;
        lastArg = _(opts).last();
        args = lastArg.fn ? _.initial(opts) : opts;
        return {
          fn: lastArg.fn,
          inverse: lastArg.inverse,
          args: args
        };
      },

      /**
       * An alias method to MixinBuilder.
       * @param  {Type} superclass A target type to mixin into.
       * @return {Type}            A result type with all mixins applied.
       */
      mix: function(superclass) {
        return new MixinBuilder(superclass, this);
      },

      /**
       * Checks if an object or a prototype has mixin prototype in
       * the inheritance chain.
       * @param  {Object|Prototype} something
       * @param  {Prototype} mixinProto
       * @return {Boolean}
       */
      withMixin: function(something, mixinProto) {
        var chain, mixinName, target, targetFunctions;
        mixinName = mixinProto.constructor.name;
        chain = Chaplin.utils.getPrototypeChain(something);
        if (target = _.find(chain, function(o) {
          return o.constructor.name === mixinName;
        })) {
          targetFunctions = _.functions(something);
          return _.functions(mixinProto).every(function(func) {
            return -1 < targetFunctions.indexOf(func);
          });
        } else {
          return false;
        }
      },

      /**
       * Checks if an object has a specific mixin in the inheritance chain.
       * @param  {Object} obj
       * @param  {Function} mixin
       * @return {Boolean}
       */
      instanceWithMixin: function(obj, mixin) {
        return this.withMixin(obj, mixin(Object).prototype);
      },

      /**
       * Checks if an class has a specific mixin in the inheritance chain.
       * @param  {Class} _class
       * @param  {Function} mixin
       * @return {Boolean}
       */
      classWithMixin: function(_class, mixin) {
        return this.withMixin(_class.prototype, mixin(Object).prototype);
      }
    });
  });

}).call(this);

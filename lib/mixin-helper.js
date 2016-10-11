(function() {
  define(function(require) {
    var Chaplin;
    Chaplin = require('chaplin');
    return {
      assertModel: function(_this) {
        if (!(_this instanceof Chaplin.Model)) {
          throw new Error('This mixin can be applied only to models.');
        }
      },
      assertNotModel: function(_this) {
        if (_this instanceof Chaplin.Model) {
          throw new Error('This mixin can not be applied to models.');
        }
      },
      assertCollection: function(_this) {
        if (!(_this instanceof Chaplin.Collection)) {
          throw new Error('This mixin can be applied only to collections.');
        }
      },
      assertNotCollection: function(_this) {
        if (_this instanceof Chaplin.Collection) {
          throw new Error('This mixin can not be applied to collections.');
        }
      },
      assertModelOrCollection: function(_this) {
        if (!(_this instanceof Chaplin.Model || _this instanceof Chaplin.Collection)) {
          throw new Error('This mixin can be applied only to models or collections.');
        }
      },
      assertView: function(_this) {
        if (!(_this instanceof Chaplin.View)) {
          throw new Error('This mixin can be applied only to views.');
        }
      },
      assertCollectionView: function(_this) {
        if (!(_this instanceof Chaplin.CollectionView)) {
          throw new Error('This mixin can be applied only to collection views.');
        }
      },
      assertViewOrCollectionView: function(_this) {
        if (!(_this instanceof Chaplin.View || _this instanceof Chaplin.CollectionView)) {
          throw new Error('This mixin can be applied only to views or collection views.');
        }
      },

      /**
       * Returns a secretly set mixin type name.
       * @param  {Object} prototype to ask for
       * @return {String}           a mixin type name
       */
      getTypeName: function(prototype) {
        return prototype.__mixinTypeName__;
      },

      /**
       * Sets a secret property with type name of the mixin. We need it for
       * reflection capabilities in runtime. To figure if an instance of a class
       * has a certain mixin applied.
       * @param {Object} prototype to check
       * @param {String} name      of a mixin to check
       */
      setTypeName: function(prototype, name) {
        return prototype.__mixinTypeName__ = name;
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
        mixinName = this.getTypeName(mixinProto);
        if (!mixinName) {
          throw new Error("The mixin " + mixinProto.constructor.name + " should have type name set. Call mixin-helper.setTypeName() on prototype.");
        }
        chain = Chaplin.utils.getPrototypeChain(something);
        if (target = _.find(chain, (function(_this) {
          return function(pro) {
            return mixinName === _this.getTypeName(pro);
          };
        })(this))) {
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
    };
  });

}).call(this);

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
      assertCollection: function(_this) {
        if (!(_this instanceof Chaplin.Collection)) {
          throw new Error('This mixin can be applied only to collections.');
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
      }
    };
  });

}).call(this);

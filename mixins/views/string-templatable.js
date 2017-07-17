(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var StringTemplatable;
        return StringTemplatable = (function(superClass) {
          var ref;

          extend(StringTemplatable, superClass);

          function StringTemplatable() {
            return StringTemplatable.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(StringTemplatable.prototype, 'StringTemplatable');

          StringTemplatable.prototype.optionNames = (ref = StringTemplatable.prototype.optionNames) != null ? ref.concat(['template']) : void 0;

          StringTemplatable.prototype.initialize = function() {
            helper.assertViewOrCollectionView(this);
            return StringTemplatable.__super__.initialize.apply(this, arguments);
          };

          StringTemplatable.prototype.getTemplateFunction = function() {
            var template;
            if (this.template) {
              if (template = require('templates')[this.template]) {
                return template;
              } else {
                throw new Error("The template file " + this.template + " doesn't exist.");
              }
            }
          };

          return StringTemplatable;

        })(superclass);
      });
    };
  });

}).call(this);

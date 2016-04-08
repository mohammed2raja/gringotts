(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    return function(superclass) {
      var StringTemplatable;
      return StringTemplatable = (function(superClass) {
        extend(StringTemplatable, superClass);

        function StringTemplatable() {
          return StringTemplatable.__super__.constructor.apply(this, arguments);
        }

        StringTemplatable.prototype.optionNames = StringTemplatable.prototype.optionNames.concat(['template']);

        StringTemplatable.prototype.templatePath = 'templates';

        StringTemplatable.prototype.getTemplateFunction = function() {
          var template;
          if (this.template) {
            if (template = require(this.templatePath)[this.template]) {
              return template;
            } else {
              throw new Error("The template file " + this.templatePath + "/" + this.template + " doesn't exist.");
            }
          }
        };

        return StringTemplatable;

      })(superclass);
    };
  });

}).call(this);

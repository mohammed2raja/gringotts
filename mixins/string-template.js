(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    return function(superclass) {
      var StringTemplate;
      return StringTemplate = (function(superClass) {
        extend(StringTemplate, superClass);

        function StringTemplate() {
          return StringTemplate.__super__.constructor.apply(this, arguments);
        }

        StringTemplate.prototype.getTemplateFunction = function() {
          var errStr, tObj;
          if (this.template) {
            tObj = require(this.templatePath)[this.template];
            if (tObj) {
              return tObj;
            } else {
              errStr = "The template file " + this.templatePath + "/" + this.template + " doesn't exist.";
              throw new Error(errStr);
            }
          }
        };

        StringTemplate.prototype.templatePath = 'templates';

        return StringTemplate;

      })(superclass);
    };
  });

}).call(this);

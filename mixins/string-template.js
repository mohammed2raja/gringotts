(function() {
  define(function(require) {
    var getTemplateFunction, templatePath;
    templatePath = '';
    getTemplateFunction = function() {
      var errStr, tObj, template;
      template = this.template;
      if (template) {
        tObj = require(templatePath)[template];
        if (tObj) {
          return tObj;
        } else {
          errStr = "The template file " + templatePath + "/" + template + " doesn't exist.";
          throw new Error(errStr);
        }
      }
    };
    return function(opts) {
      if (opts == null) {
        opts = {};
      }
      templatePath = opts.templatePath || 'views/templates';
      this.getTemplateFunction = getTemplateFunction;
      return this;
    };
  });

}).call(this);

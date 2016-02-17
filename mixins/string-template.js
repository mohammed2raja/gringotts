(function() {
  define(function(require) {
    var getTemplateFunction;
    getTemplateFunction = function(templatePath) {
      var errStr, tObj, template;
      if (templatePath == null) {
        templatePath = '';
      }
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
      this.getTemplateFunction = function() {
        return getTemplateFunction.call(this, opts.templatePath || 'templates');
      };
      return this;
    };
  });

}).call(this);

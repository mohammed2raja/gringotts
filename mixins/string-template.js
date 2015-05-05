(function() {
  define(function(require, exports) {
    var getTemplateFunction, templatePath;
    templatePath = '';
    getTemplateFunction = function() {
      var errString, tObj, template;
      template = this.template;
      if (template) {
        tObj = require(templatePath)[template];
        if (tObj) {
          return tObj;
        } else {
          errString = "The template file " + templatePath + "/" + template + " does not exist.";
          throw new Error(errString);
        }
      }
    };
    return exports = function(opts) {
      if (opts == null) {
        opts = {};
      }
      templatePath = opts.templatePath || 'views/templates';
      this.getTemplateFunction = getTemplateFunction;
      return this;
    };
  });

}).call(this);

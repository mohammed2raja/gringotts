(function() {
  define(function(require) {
    return {
      getTemplateFunction: function() {
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
      },
      templatePath: 'templates'
    };
  });

}).call(this);

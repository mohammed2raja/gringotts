(function() {
  define(function(require, exports) {
    var blank, _;
    _ = require('underscore');
    blank = function(text) {
      return text.length === 0;
    };
    return exports = function(opts) {
      var methods;
      methods = opts.methods;
      this.validate = function(attrs, options) {
        var errors, foundError;
        foundError = false;
        errors = _.reduce(methods, function(memo, name, attr) {
          var method, modelErr;
          method = this[name] || blank;
          if (attrs.hasOwnProperty(attr)) {
            modelErr = method.call(this, attrs[attr]);
          }
          if (modelErr) {
            foundError = true;
            memo[attr] = modelErr;
          }
          return memo;
        }, {}, this);
        if (foundError) {
          return errors;
        }
      };
      return this;
    };
  });

}).call(this);

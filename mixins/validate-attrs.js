(function() {
  define(function(require) {
    var blank;
    blank = function(text) {
      var message;
      message = (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.validation.value_required') : void 0) || 'Value Required';
      if (!text || text.length === 0) {
        return message;
      }
    };
    return function(opts) {
      var methods;
      methods = opts.methods;
      this.validate = function(attrs, options) {
        var errors, foundError;
        foundError = false;
        errors = _.reduce(methods, (function(_this) {
          return function(memo, name, attr) {
            var method, modelErr;
            method = _this[name] || blank;
            if (attrs.hasOwnProperty(attr)) {
              modelErr = method.call(_this, attrs[attr]);
            }
            if (modelErr) {
              foundError = true;
              memo[attr] = modelErr;
            }
            return memo;
          };
        })(this), {});
        if (foundError) {
          return errors;
        }
      };
      return this;
    };
  });

}).call(this);

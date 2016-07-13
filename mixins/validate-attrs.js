(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var blank;
    blank = function(text) {
      var message;
      message = (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.validation.value_required') : void 0) || 'Value Required';
      if (!text || text.length === 0) {
        return message;
      }
    };
    return function(superclass) {
      var ValidateAttrs;
      return ValidateAttrs = (function(superClass) {
        extend(ValidateAttrs, superClass);

        function ValidateAttrs() {
          return ValidateAttrs.__super__.constructor.apply(this, arguments);
        }

        ValidateAttrs.prototype.validateAttrs = {};

        ValidateAttrs.prototype.validate = function(attrs, options) {
          var errors, foundError;
          foundError = false;
          errors = _.reduce(this.validateAttrs, (function(_this) {
            return function(memo, name, attr) {
              var method, modelErr;
              method = _this[name] || blank;
              if (attrs.hasOwnProperty(attr) || method === blank && (options != null ? options.validate : void 0)) {
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

        return ValidateAttrs;

      })(superclass);
    };
  });

}).call(this);

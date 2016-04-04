(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var errorBlock, selectorFns;
    selectorFns = {
      id: function(field) {
        return "#" + field;
      },
      "class": function(field) {
        return "." + field;
      },
      other: function(field, attr) {
        return "[" + attr + "='" + field + "']";
      }
    };
    errorBlock = function(error) {
      return "<p class='help-block'>" + error + "</p>";
    };
    return function(superclass) {
      var FormErrors;
      return FormErrors = (function(superClass) {
        extend(FormErrors, superClass);

        function FormErrors() {
          return FormErrors.__super__.constructor.apply(this, arguments);
        }

        FormErrors.prototype.genericErrMsg = 'There was a problem. Please try again.';

        FormErrors.prototype.specificErrors = false;

        FormErrors.prototype.inputAttr = 'name';

        FormErrors.prototype._formErrorSelector = function(field) {
          return (selectorFns[this.inputAttr] || selectorFns.other)(field, this.inputAttr);
        };

        FormErrors.prototype.genericError = function(error) {
          return this.$('form:first').prepend(errorBlock(error));
        };

        FormErrors.prototype.specificError = function(query, error) {
          return this.$(query + ":first").after(errorBlock(error));
        };

        FormErrors.prototype.parseErrors = function(errors) {
          if (!errors || _.isEmpty(errors)) {
            return this.genericError(this.genericErrMsg);
          }
          if (_.isArray(errors.generic) && errors.generic.length > 0) {
            return _.each(errors.generic, (function(_this) {
              return function(err) {
                return _this.genericError(err);
              };
            })(this));
          } else {
            if (this.specificErrors) {
              this.trigger('specificErrors:before', errors);
            }
            return _.each(errors, (function(_this) {
              return function(val, field) {
                return _this.specificError(_this._formErrorSelector(field), errors[field]);
              };
            })(this));
          }
        };

        return FormErrors;

      })(superclass);
    };
  });

}).call(this);

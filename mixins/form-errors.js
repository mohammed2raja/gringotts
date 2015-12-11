(function() {
  define(function(require) {
    var errorBlock, genericErrMsg, genericError, parseErrors, selectedAttr, selector, selectorFns, specificError, specificErrors, _;
    _ = require('underscore');
    selectorFns = {
      id: function(field) {
        return "#" + field;
      },
      "class": function(field) {
        return "." + field;
      },
      other: function(field) {
        return "[" + selectedAttr + "='" + field + "']";
      }
    };
    genericErrMsg = '';
    selector = '';
    selectedAttr = '';
    specificErrors = false;
    errorBlock = function(error) {
      return "<p class='help-block'>" + error + "</p>";
    };
    genericError = function(error) {
      return this.$('form:first').prepend(errorBlock(error));
    };
    specificError = function(query, error) {
      return this.$("" + query + ":first").after(errorBlock(error));
    };
    parseErrors = function(errors) {
      var errorStrings;
      if (!errors || _.isEmpty(errors)) {
        return this.genericError(genericErrMsg);
      }
      errorStrings = errors.generic;
      if (_.isArray(errorStrings) && errorStrings.length > 0) {
        return _.each(errorStrings, function(err) {
          return this.genericError(err);
        }, this);
      } else {
        if (specificErrors) {
          this.trigger('specificErrors:before', errors);
        }
        return _.each(errors, function(val, field) {
          return this.specificError(selector(field), errors[field]);
        }, this);
      }
    };
    return function(opts) {
      if (opts == null) {
        opts = {};
      }
      genericErrMsg = opts.genericErrMsg || 'There was a problem. Please try again.';
      specificErrors = opts.specificErrors;
      selectedAttr = opts.inputAttr || 'name';
      selector = selectorFns[selectedAttr] || selectorFns.other;
      this.genericError = genericError;
      this.specificError = specificError;
      this.parseErrors = parseErrors;
      return this;
    };
  });

}).call(this);

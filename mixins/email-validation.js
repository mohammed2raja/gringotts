(function() {
  define(function(require) {
    var regex;
    regex = /^(([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return function() {
      this.validateEmail = function(email) {
        var message;
        message = (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.validation.invalid_email') : void 0) || 'Invalid Email';
        if (!regex.test(email)) {
          return message;
        }
      };
      this.getEmailRegex = function() {
        return regex;
      };
      return this;
    };
  });

}).call(this);

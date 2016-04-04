(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var regex;
    regex = /^(([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return function(superclass) {
      var EmailValidation;
      return EmailValidation = (function(superClass) {
        extend(EmailValidation, superClass);

        function EmailValidation() {
          return EmailValidation.__super__.constructor.apply(this, arguments);
        }

        EmailValidation.prototype.validateEmail = function(email) {
          var message;
          message = (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.validation.invalid_email') : void 0) || 'Invalid Email';
          if (!regex.test(email)) {
            return message;
          }
        };

        EmailValidation.prototype.getEmailRegex = function() {
          return regex;
        };

        return EmailValidation;

      })(superclass);
    };
  });

}).call(this);

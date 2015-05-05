(function() {
  define(function(require, exports) {
    var regex;
    regex = /^(([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return exports = function() {
      this.validateEmail = function(email) {
        return !regex.test(email);
      };
      this.getEmailRegex = function() {
        return regex;
      };
      return this;
    };
  });

}).call(this);

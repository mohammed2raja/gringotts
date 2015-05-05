(function() {
  define(function(require, exports) {
    var advice;
    advice = require('flight/advice');
    return exports = function() {
      if (!this.before) {
        advice.withAdvice.call(this);
      }
      return this;
    };
  });

}).call(this);

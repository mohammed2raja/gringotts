(function() {
  define(function(require) {
    var advice;
    advice = require('flight/advice');
    return function() {
      if (!this.before) {
        advice.withAdvice.call(this);
      }
      return this;
    };
  });

}).call(this);

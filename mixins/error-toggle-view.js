(function() {
  define(function(require, exports) {
    return exports = function() {
      this.before('delegateListeners', function() {
        var selector;
        selector = this.errorSelector || '.service-error';
        this.delegateListener('service-unavailable', 'collection', function() {
          return this.$(selector).show();
        });
        return this.delegateListener('syncStateChange', 'collection', function() {
          return this.$(selector).hide();
        });
      });
      return this;
    };
  });

}).call(this);

(function() {
  define(function(require) {
    var parse;
    parse = function(resp) {
      if (this.syncKey) {
        this.count = parseInt(resp.count);
        return resp[this.syncKey];
      } else {
        return resp;
      }
    };
    return function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.parse = parse;
      return this;
    };
  });

}).call(this);

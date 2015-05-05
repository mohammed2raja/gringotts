(function() {
  define(function(require, exports) {
    var parse;
    parse = function(resp) {
      if (this.syncKey) {
        this.count = resp.count;
        return resp[this.syncKey];
      } else {
        return resp;
      }
    };
    return exports = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.parse = parse;
      return this;
    };
  });

}).call(this);

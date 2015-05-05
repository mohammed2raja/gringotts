(function() {
  define(function() {
    if (window.PHANTOMJS) {
      return window.ProgressEvent = function(type, params) {
        params = params || {};
        this.lengthComputable = params.lengthComputable || false;
        this.loaded = params.loaded || 0;
        return this.total = params.total || 0;
      };
    }
  });

}).call(this);

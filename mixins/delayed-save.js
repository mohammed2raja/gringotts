(function() {
  define(function(require, exports) {
    var successHandler;
    successHandler = function(opts) {
      return this.publishEvent('notify', opts.saveMessage, {
        model: opts.model,
        success: function() {
          return opts.model.save(opts.attribute, opts.value, {
            patch: opts.patch,
            validate: false
          });
        },
        undo: (function(_this) {
          return function() {
            opts.$field.text(opts.original);
            if (opts.href) {
              opts.$field.attr('href', opts.href);
            }
            return _this.makeEditable(opts);
          };
        })(this)
      });
    };
    return exports = function() {
      this.delayedSave = successHandler;
      return this;
    };
  });

}).call(this);

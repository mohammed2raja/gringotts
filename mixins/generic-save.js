(function() {
  define(function(require) {
    var _revertChanges, genericSave;
    _revertChanges = function(opts) {
      var ref, ref1;
      if ((ref = opts.$field) != null) {
        ref.text(opts.original);
      }
      if (opts.href) {
        if ((ref1 = opts.$field) != null) {
          ref1.attr('href', opts.href);
        }
      }
      return typeof this.makeEditable === "function" ? this.makeEditable(opts) : void 0;
    };
    genericSave = function(opts) {
      opts = _.extend({}, opts, {
        validate: false
      });
      if (opts.delayedSave) {
        return this.publishEvent('notify', opts.saveMessage, _.extend({}, opts, {
          success: function() {
            return opts.model.save(opts.attribute, opts.value, _.extend({}, opts, {
              error: (function(_this) {
                return function() {
                  return _revertChanges.call(_this, opts);
                };
              })(this)
            }));
          },
          undo: (function(_this) {
            return function() {
              return _revertChanges.call(_this, opts);
            };
          })(this)
        }));
      } else {
        return opts.model.save(opts.attribute, opts.value, _.extend({}, opts, {
          success: (function(_this) {
            return function() {
              return _this.publishEvent('notify', opts.saveMessage);
            };
          })(this),
          error: (function(_this) {
            return function() {
              return _revertChanges.call(_this, opts);
            };
          })(this)
        }));
      }
    };
    return function() {
      this.genericSave = genericSave;
      return this;
    };
  });

}).call(this);

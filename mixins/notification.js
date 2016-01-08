(function() {
  define(function(require) {
    var advice, afterRender, delegateHandlers, dismiss, fadeSpeed, getUndoElement, navigateDismiss, notificationTimeout, reqTimeout, undoSelector;
    advice = require('flight/advice');
    fadeSpeed = 0;
    reqTimeout = 0;
    undoSelector = '';
    notificationTimeout = null;
    getUndoElement = function() {
      return "<a class='undo' href='javascript:;'> Undo </a>";
    };
    afterRender = function() {
      var opts, ref, timeout;
      opts = this.model.get('opts') || {};
      if (opts.undo) {
        $(undoSelector).remove();
        opts.link = this.getUndoElement();
      }
      if (opts.link) {
        this.$el.append(opts.link);
      }
      if ((ref = opts.deferred) != null) {
        ref.done((function(_this) {
          return function() {
            return _this.dismiss();
          };
        })(this));
      }
      if (!opts.sticky) {
        timeout = opts.reqTimeout || reqTimeout;
        return this.model.timeout = notificationTimeout = window.setTimeout((function(_this) {
          return function() {
            if (typeof opts.success === "function") {
              opts.success();
            }
            return _this.dismiss();
          };
        })(this), timeout);
      }
    };
    dismiss = function() {
      var ref;
      return (ref = this.$el) != null ? ref.animate({
        opacity: 0
      }, fadeSpeed, (function(_this) {
        return function() {
          if (!_this.disposed) {
            return _this.model.dispose();
          }
        };
      })(this)) : void 0;
    };
    navigateDismiss = function() {
      var opts;
      opts = this.model.get('opts') || {};
      if (opts.navigateDismiss) {
        return this.subscribeEvent('dispatcher:dispatch', function() {
          return this.dismiss();
        });
      }
    };
    delegateHandlers = function() {
      var classes, opts;
      this.delegate('click', '.close', function(e) {
        e.preventDefault();
        e.stopPropagation();
        return this.dismiss();
      });
      opts = this.model.get('opts') || {};
      if (opts.model) {
        this.listenTo(opts.model, 'dispose', function() {
          window.clearTimeout(notificationTimeout);
          if (typeof opts.success === "function") {
            opts.success();
          }
          return this.dismiss();
        });
      }
      if (opts.undo) {
        opts.click = {
          selector: undoSelector,
          handler: function(e) {
            e.preventDefault();
            window.clearTimeout(notificationTimeout);
            opts.undo();
            return this.dismiss();
          }
        };
      }
      if (opts.click) {
        this.delegate('click', opts.click.selector, opts.click.handler);
      }
      classes = opts.classes || 'alert-success';
      return this.$el.addClass(classes);
    };
    return function(opts) {
      if (opts == null) {
        opts = {};
      }
      undoSelector = opts.undoSelector || '.undo';
      fadeSpeed = typeof opts.fadeSpeed === 'number' ? opts.fadeSpeed : 500;
      reqTimeout = typeof opts.reqTimeout === 'number' ? opts.reqTimeout : 4000;
      this.getUndoElement = getUndoElement;
      this.dismiss = dismiss;
      this.after('attach', delegateHandlers);
      this.after('initialize', navigateDismiss);
      this.after('render', afterRender);
      return this;
    };
  });

}).call(this);

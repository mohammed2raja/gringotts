(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var NotificationView, View, notificationTimeout, templates;
    templates = require('templates');
    View = require('./base/view');
    notificationTimeout = null;
    return NotificationView = (function(superClass) {
      extend(NotificationView, superClass);

      function NotificationView() {
        return NotificationView.__super__.constructor.apply(this, arguments);
      }

      NotificationView.prototype.template = 'notification';

      NotificationView.prototype.tagName = 'li';

      NotificationView.prototype.className = 'alert alert-success alert-dismissable';

      NotificationView.prototype.optionNames = NotificationView.prototype.optionNames.concat(['undoSelector', 'fadeSpeed', 'reqTimeout']);

      NotificationView.prototype.undoSelector = '.undo';

      NotificationView.prototype.fadeSpeed = 500;

      NotificationView.prototype.reqTimeout = 4000;

      NotificationView.prototype.initialize = function() {
        NotificationView.__super__.initialize.apply(this, arguments);
        return this.navigateDismiss();
      };

      NotificationView.prototype.getUndoElement = function() {
        return templates['notification-undo']({
          label: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('notifications.undo') : void 0) || 'Undo'
        });
      };

      NotificationView.prototype.navigateDismiss = function() {
        var opts;
        opts = this.model.get('opts') || {};
        if (opts.navigateDismiss) {
          return this.subscribeEvent('dispatcher:dispatch', function() {
            return this.dismiss();
          });
        }
      };

      NotificationView.prototype.dismiss = function() {
        var ref;
        return (ref = this.$el) != null ? ref.animate({
          opacity: 0
        }, this.fadeSpeed, (function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this.model.dispose();
            }
          };
        })(this)) : void 0;
      };

      NotificationView.prototype.render = function() {
        var opts, ref, timeout;
        NotificationView.__super__.render.apply(this, arguments);
        opts = this.model.get('opts') || {};
        if (opts.undo) {
          $(this.undoSelector).remove();
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
          timeout = opts.reqTimeout || this.reqTimeout;
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

      NotificationView.prototype.attach = function() {
        var classes, opts;
        NotificationView.__super__.attach.apply(this, arguments);
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
            selector: this.undoSelector,
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

      return NotificationView;

    })(View);
  });

}).call(this);

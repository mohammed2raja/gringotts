(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Classy, ModalView, View;
    Classy = require('../../mixins/classy');
    View = require('./view');

    /**
     * View for bootstrap modals
     */
    return ModalView = (function(superClass) {
      extend(ModalView, superClass);

      function ModalView() {
        return ModalView.__super__.constructor.apply(this, arguments);
      }

      ModalView.prototype.classyName = 'modal fade';

      ModalView.prototype.attributes = {
        tabindex: -1,
        role: 'dialog'
      };

      ModalView.prototype.events = {
        'shown.bs.modal': function() {
          return $('body').addClass('no-scroll');
        },
        'hidden.bs.modal': function() {
          $('body').removeClass('no-scroll');
          this.hidden = true;
          if (this.disposeRequested || !(this.model || this.collection)) {
            return this.dispose();
          }
        }
      };

      ModalView.prototype.attach = function(opts) {
        ModalView.__super__.attach.apply(this, arguments);
        return this.$el.modal(opts);
      };

      ModalView.prototype.hide = function() {
        if (this.$el && this.$el.hasClass('in')) {
          return this.$el.modal('hide');
        }
      };

      ModalView.prototype.dispose = function() {
        this.hide();
        if (this.hidden) {
          ModalView.__super__.dispose.apply(this, arguments);
        }
        return this.disposeRequested = true;
      };

      return ModalView;

    })(Classy(View));
  });

}).call(this);

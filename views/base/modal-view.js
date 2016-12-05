(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Classy, ModalView, View;
    Classy = require('../../mixins/views/classy');
    View = require('./view');

    /**
     * Base View for bootstrap modals.
     * The instance of this modal view should be always added into 'subviews' of
     * the parent host Chaplin.View that initiates modal creation.
     * This will guarantee that modal view is disposed when host view is disposed.
     */
    return ModalView = (function(superClass) {
      extend(ModalView, superClass);

      function ModalView() {
        return ModalView.__super__.constructor.apply(this, arguments);
      }

      ModalView.prototype.classyName = 'modal fade';

      ModalView.prototype.attributes = {
        role: 'dialog'
      };

      ModalView.prototype.events = {
        'shown.bs.modal': function() {
          return this.onShown();
        },
        'hidden.bs.modal': function() {
          return this.onHidden();
        }
      };

      ModalView.prototype.attach = function(opts) {
        ModalView.__super__.attach.apply(this, arguments);
        return this.$el.modal(opts);
      };

      ModalView.prototype.show = function() {
        if (this.disposed) {
          return;
        }
        this.delegateEvents();
        this.delegateListeners();
        this.render();
        return this.attach();
      };

      ModalView.prototype.hide = function() {
        if (this.disposed) {
          return;
        }
        if (this.$el && this.$el.hasClass('in')) {
          return this.$el.modal('hide');
        }
      };

      ModalView.prototype.onShown = function() {
        this.modalVisible = true;
        $('body').addClass('no-scroll');
        return this.trigger('shown');
      };

      ModalView.prototype.onHidden = function() {
        this.modalVisible = false;
        $('body').removeClass('no-scroll');
        this.trigger('hidden');
        if (!this.disposed) {
          return this.remove();
        }
      };

      ModalView.prototype.dispose = function() {
        if (this.modalVisible) {
          this.once('hidden', function() {
            return ModalView.__super__.dispose.apply(this, arguments);
          });
          return this.hide();
        } else {
          return ModalView.__super__.dispose.apply(this, arguments);
        }
      };

      return ModalView;

    })(Classy(View));
  });

}).call(this);

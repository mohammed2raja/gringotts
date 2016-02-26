(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ModalView, View;
    View = require('./view');

    /**
     * View for bootstrap modals
     * @constructor
     */
    return ModalView = (function(superClass) {
      extend(ModalView, superClass);

      function ModalView() {
        return ModalView.__super__.constructor.apply(this, arguments);
      }

      ModalView.prototype.optionNames = View.prototype.optionNames.concat(['forceOneInstance']);

      ModalView.prototype.className = 'modal';

      ModalView.prototype.attributes = {
        tabindex: -1,
        role: 'dialog'
      };

      ModalView.prototype.attach = function(opts) {
        var $body;
        ModalView.__super__.attach.apply(this, arguments);
        if (!!this.forceOneInstance && (this.template != null) && $("." + this.template).length) {
          this.dispose();
          return;
        }
        $body = $('body');
        this.$el.on('shown.bs.modal', function() {
          return $body.addClass('no-scroll');
        });
        this.$el.on('hidden.bs.modal', (function(_this) {
          return function() {
            $body.removeClass('no-scroll');
            return _this.dispose();
          };
        })(this));
        return this.$el.modal(opts);
      };

      ModalView.prototype.dispose = function() {
        var ref;
        if ((ref = this.$el) != null) {
          ref.modal('hide');
        }
        return ModalView.__super__.dispose.apply(this, arguments);
      };

      return ModalView;

    })(View);
  });

}).call(this);

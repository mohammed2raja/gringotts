(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var DialogView, ModalView;
    ModalView = require('./base/modal-view');
    return DialogView = (function(superClass) {
      extend(DialogView, superClass);

      function DialogView() {
        return DialogView.__super__.constructor.apply(this, arguments);
      }

      DialogView.prototype.template = 'dialog';

      DialogView.prototype.title = null;

      DialogView.prototype.text = null;

      DialogView.prototype.buttons = [
        {
          text: 'OK',
          className: 'btn-action'
        }
      ];

      DialogView.prototype.optionNames = ModalView.prototype.optionNames.concat(['title', 'text', 'buttons']);

      DialogView.prototype.events = {
        'click button': function(e) {
          var $el;
          $el = $(e.currentTarget);
          return this.buttons.forEach((function(_this) {
            return function(b) {
              if (b.click && $el.hasClass(b.className)) {
                return b.click.call(_this, e);
              }
            };
          })(this));
        }
      };

      DialogView.prototype.getTemplateData = function() {
        return _.extend(DialogView.__super__.getTemplateData.apply(this, arguments), {
          title: this.title,
          text: this.text,
          buttons: this.buttons
        });
      };

      return DialogView;

    })(ModalView);
  });

}).call(this);

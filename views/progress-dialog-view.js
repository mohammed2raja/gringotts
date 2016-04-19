(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ModalView, ProgressDialogView, STATES, templates;
    ModalView = require('./base/modal-view');
    templates = require('templates');
    STATES = ['default', 'progress', 'error', 'success'];

    /**
    * A dialog view that shows the pulsing progress indicator
    * during model's activity.
    * On model synced, displays the success view.
    * On model error, displays the error view with an option to try again.
    * Initialized with set of key objects (states):
    *   <default, progress, error, success>:
    *     title: String
    *     text: <String, Function>
    *     buttons: [{text: String, className: String, click: Function}]
    * State text can be a Handlebars template function.
    * If a button doesn't have click handler, it will close dialog on click.
     */
    return ProgressDialogView = (function(superClass) {
      extend(ProgressDialogView, superClass);

      function ProgressDialogView() {
        return ProgressDialogView.__super__.constructor.apply(this, arguments);
      }

      ProgressDialogView.prototype.optionNames = ProgressDialogView.prototype.optionNames.concat(STATES, ['state', 'onDone', 'onCancel']);

      ProgressDialogView.prototype.className = 'progress-dialog';

      ProgressDialogView.prototype.template = 'progress-dialog';

      ProgressDialogView.prototype.onDone = null;

      ProgressDialogView.prototype.onCancel = null;

      ProgressDialogView.prototype.state = null;

      ProgressDialogView.prototype.listen = {
        'syncing model': function() {
          return this.onSyncing();
        },
        'synced model': function() {
          return this.onSynced();
        },
        'error model': function(model, $xhr) {
          return this.onError($xhr);
        }
      };

      ProgressDialogView.prototype.events = {
        'click button': function(e) {
          var $btn, ref;
          $btn = $(e.currentTarget);
          if ($btn.data('dismiss') === 'modal') {
            return this.$("." + this.state + "-view").removeClass('fade');
          } else {
            return (ref = this[this.state]) != null ? ref.buttons.forEach((function(_this) {
              return function(b) {
                if (b.click && $btn.hasClass(b.className)) {
                  return b.click.call(_this, e);
                }
              };
            })(this)) : void 0;
          }
        },
        'hidden.bs.modal': function() {
          if (this.state === 'success') {
            return typeof this.onDone === "function" ? this.onDone() : void 0;
          } else {
            return typeof this.onCancel === "function" ? this.onCancel() : void 0;
          }
        }
      };

      ProgressDialogView.prototype.initialize = function() {
        var ref;
        ProgressDialogView.__super__.initialize.apply(this, arguments);
        if (!_.isFunction(this.model.isSyncing)) {
          throw Error('Requires a model implementing SyncMachine');
        }
        _.defaultsDeep(this, {
          "default": {
            buttons: [
              {
                text: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('buttons.OK') : void 0) || 'OK',
                className: 'btn-action'
              }
            ]
          },
          error: {
            title: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.did_not_work') : void 0) || "Hmm. That didn't seem to work. Try again?",
            buttons: _([
              {
                text: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('buttons.cancel') : void 0) || 'Cancel',
                className: 'btn-cancel'
              }
            ]).concat(_.extend(_.clone(_.first(_.filter((ref = this["default"]) != null ? ref.buttons : void 0, function(b) {
              return b.click;
            }))), {
              text: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('buttons.try_again') : void 0) || 'Try again'
            })).value()
          },
          success: {
            html: (function(_this) {
              return function() {
                return templates['progress-success'](_this.getTemplateData());
              };
            })(this),
            buttons: [
              {
                text: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('buttons.Okay') : void 0) || 'Okay',
                className: 'btn-action'
              }
            ]
          }
        });
        STATES.forEach((function(_this) {
          return function(s) {
            if (_this[s] && _.isFunction(_this[s].text)) {
              return _this[s].html = function() {
                return _this[s].text(_this.getTemplateData());
              };
            }
          };
        })(this));
        if (!this.state) {
          return this.state = this.progressState();
        }
      };

      ProgressDialogView.prototype.getTemplateData = function() {
        return _.extend(ProgressDialogView.__super__.getTemplateData.apply(this, arguments), {
          state: this.state
        }, _.reduce(STATES, (function(_this) {
          return function(data, state) {
            data[state] = _this[state];
            return data;
          };
        })(this), {}));
      };

      ProgressDialogView.prototype.render = function() {
        ProgressDialogView.__super__.render.apply(this, arguments);
        if (this.model.isSyncing()) {
          return this.onSyncing();
        }
      };

      ProgressDialogView.prototype.onSyncing = function() {
        this.setLoading(true);
        return this.switchTo(this.progressState());
      };

      ProgressDialogView.prototype.onSynced = function() {
        this.setLoading(false);
        return this.switchTo('success');
      };

      ProgressDialogView.prototype.onError = function($xhr) {
        $xhr.errorHandled = true;
        this.setLoading(false);
        return this.switchTo('error');
      };

      ProgressDialogView.prototype.switchTo = function(state) {
        var ref;
        if (this.state === state) {
          return;
        }
        this.state = state;
        if ((ref = this[state]) != null ? ref.html : void 0) {
          this.$("." + state + "-view .modal-body").html(this[state].html());
        }
        return _.each(STATES, (function(_this) {
          return function(s) {
            return _this.$("." + s + "-view").addClass('fade').toggleClass('in', s === state && !_this.empty(state));
          };
        })(this));
      };

      ProgressDialogView.prototype.empty = function(state) {
        if (!this[state]) {
          return true;
        }
        return !this[state].title && !this[state].text && !this[state].html;
      };

      ProgressDialogView.prototype.setLoading = function(loading) {
        return this.$('.loading').toggleClass('in', loading);
      };

      ProgressDialogView.prototype.progressState = function() {
        if (this.model.isSyncing() && this.progress) {
          return 'progress';
        } else {
          return 'default';
        }
      };

      return ProgressDialogView;

    })(ModalView);
  });

}).call(this);

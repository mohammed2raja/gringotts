(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ErrorHandling, helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');
    ErrorHandling = require('./error-handling');
    return function(base) {
      var GenericSave;
      return GenericSave = (function(superClass) {
        extend(GenericSave, superClass);

        function GenericSave() {
          return GenericSave.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(GenericSave.prototype, 'GenericSave');

        GenericSave.prototype.initialize = function() {
          helper.assertViewOrCollectionView(this);
          return GenericSave.__super__.initialize.apply(this, arguments);
        };

        GenericSave.prototype.genericSave = function(opts) {
          opts = _.extend({}, _.omit(opts, ['success']), {
            wait: true,
            validate: false
          });
          if (opts.delayedSave) {
            return this.publishEvent('notify', opts.saveMessage, _.extend({}, opts, {
              success: (function(_this) {
                return function() {
                  return opts.model.save(opts.attribute, opts.value, opts)["catch"](function($xhr) {
                    return _this.genericSaveRevert(opts, $xhr);
                  })["catch"](_this.handleError);
                };
              })(this),
              undo: (function(_this) {
                return function() {
                  return _this.genericSaveRevert(opts);
                };
              })(this)
            }));
          } else {
            return opts.model.save(opts.attribute, opts.value, opts).then((function(_this) {
              return function() {
                return _this.publishEvent('notify', opts.saveMessage);
              };
            })(this))["catch"]((function(_this) {
              return function($xhr) {
                return _this.genericSaveRevert(opts, $xhr);
              };
            })(this))["catch"](this.handleError);
          }
        };

        GenericSave.prototype.genericSaveRevert = function(opts, $xhr) {
          var message, ref, ref1, ref2, ref3, response;
          if ((ref = opts.$field) != null) {
            ref.text(opts.original);
          }
          if (opts.href) {
            if ((ref1 = opts.$field) != null) {
              ref1.attr('href', opts.href);
            }
          }
          if (!$xhr) {
            if (typeof this.makeEditable === "function") {
              this.makeEditable(opts);
            }
          }
          if ($xhr) {
            if ((ref2 = $xhr.status) === 400 || ref2 === 406) {
              if (response = utils.parseJSON($xhr.responseText)) {
                if (message = response.error || ((ref3 = response.errors) != null ? ref3[opts.attribute] : void 0)) {
                  this.notifyError(message);
                  return;
                }
              }
            }
            return $xhr;
          }
        };

        return GenericSave;

      })(utils.mix(base)["with"](ErrorHandling));
    };
  });

}).call(this);

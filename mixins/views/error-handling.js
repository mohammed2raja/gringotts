(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, parseResponse, resolveMessage, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');
    parseResponse = function($xhr) {
      var error;
      try {
        return utils.parseJSON($xhr.responseText);
      } catch (error) {
        return null;
      }
    };
    resolveMessage = function(response) {
      return (response != null ? response.error : void 0) || (response != null ? response.message : void 0);
    };
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var ErrorHandling;
        return ErrorHandling = (function(superClass) {
          extend(ErrorHandling, superClass);

          function ErrorHandling() {
            this.handleError = bind(this.handleError, this);
            return ErrorHandling.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(ErrorHandling.prototype, 'ErrorHandling');

          ErrorHandling.prototype.listen = {
            'promise-error model': function(m, e) {
              return this.handleError(e);
            },
            'promise-error collection': function(m, e) {
              return this.handleError(e);
            }
          };

          ErrorHandling.prototype.initialize = function() {
            helper.assertViewOrCollectionView(this);
            return ErrorHandling.__super__.initialize.apply(this, arguments);
          };


          /**
           * Generic error handler. Works with an Error and XHR instances.
           */

          ErrorHandling.prototype.handleError = function(obj) {
            var $xhr, ref;
            if (obj.status != null) {
              $xhr = obj;
              if ($xhr.statusText === 'abort') {
                return this.markAsHandled($xhr);
              } else if ((ref = $xhr.status) !== 200 && ref !== 201) {
                return this.handleAny($xhr);
              }
            } else {
              this.logError(obj);
              return this.markAsHandled(obj);
            }
          };


          /**
           * Any XHR error handler.
           */

          ErrorHandling.prototype.handleAny = function($xhr) {
            var message, response;
            response = parseResponse($xhr);
            message = resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.notification') : void 0) || 'There was a problem communicating with the server.';
            this.notifyError(message);
            return this.markAsHandled($xhr);
          };

          ErrorHandling.prototype.notifyError = function(message) {
            return this.publishEvent('notify', message, {
              classes: 'alert-danger'
            });
          };

          ErrorHandling.prototype.logError = function(obj) {
            if (!(window.console && window.console.warn)) {
              return;
            }
            return window.console.warn(obj);
          };

          ErrorHandling.prototype.markAsHandled = function(obj) {
            return obj.errorHandled = true;
          };

          return ErrorHandling;

        })(superclass);
      });
    };
  });

}).call(this);

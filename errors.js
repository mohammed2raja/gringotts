(function() {
  define(function(require) {
    var Chaplin, DEFAULTS, _, _handle, _handle401, _handle403, _parseResponse, _resolveMessage, utils;
    _ = require('underscore');
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    DEFAULTS = {
      classes: 'alert-danger',
      reqTimeout: 10000
    };
    _parseResponse = function($xhr) {
      var error;
      try {
        return utils.parseJSON($xhr.responseText);
      } catch (error) {
        return null;
      }
    };
    _resolveMessage = function(response) {
      return (response != null ? response.error : void 0) || (response != null ? response.message : void 0);
    };
    _handle401 = function(context, $xhr) {
      var response;
      response = _parseResponse($xhr);
      if (response.CODE === 'SESSION_EXPIRED') {
        return (context || window).location.reload();
      }
    };
    _handle403 = function(context, $xhr) {
      var message, response;
      response = _parseResponse($xhr);
      utils.redirectTo({});
      message = _resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.no_access') : void 0) || "Sorry, you don't have access to that section of the application.";
      (context || Chaplin.EventBroker).publishEvent('notify', message, DEFAULTS);
      return $xhr.errorHandled = true;
    };
    _handle = function(context, $xhr) {
      var message, response;
      response = _parseResponse($xhr);
      message = _resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.notification') : void 0) || 'There was a problem communicating with the server.';
      (context || Chaplin.EventBroker).publishEvent('notify', message, DEFAULTS);
      return $xhr.errorHandled = true;
    };
    return {
      setupErrorHandling: function(context) {
        return $(document).ajaxError(function(event, $xhr) {
          var errorHandled, status;
          status = $xhr.status, errorHandled = $xhr.errorHandled;
          if (status === 401) {
            return _handle401(context, $xhr);
          } else if (status === 403 && !errorHandled) {
            return _handle403(context, $xhr);
          } else if ((status !== 0 && status !== 200 && status !== 201) && !errorHandled) {
            return _handle(context, $xhr);
          }
        });
      }
    };
  });

}).call(this);

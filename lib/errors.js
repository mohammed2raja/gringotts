(function() {
  define(function(require) {
    var Chaplin, handle, handle401, handle403, parseResponse, resolveMessage, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
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
    handle401 = function(context, $xhr) {
      return (context || window).location.reload();
    };
    handle403 = function(context, $xhr) {
      var message, response;
      response = parseResponse($xhr);
      utils.redirectTo({});
      message = resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.no_access') : void 0) || "Sorry, you don't have access to that section of the application.";
      (context || Chaplin.EventBroker).publishEvent('notify', message, {
        classes: 'alert-danger'
      });
      return $xhr.errorHandled = true;
    };
    handle = function(context, $xhr) {
      var message, response;
      response = parseResponse($xhr);
      message = resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.notification') : void 0) || 'There was a problem communicating with the server.';
      (context || Chaplin.EventBroker).publishEvent('notify', message, {
        classes: 'alert-danger'
      });
      return $xhr.errorHandled = true;
    };
    return {
      setupErrorHandling: function(context) {
        return $(document).ajaxError(function(event, $xhr) {
          var errorHandled, status;
          status = $xhr.status, errorHandled = $xhr.errorHandled;
          if (status === 401) {
            return handle401(context, $xhr);
          } else if (status === 403 && !errorHandled) {
            return handle403(context, $xhr);
          } else if ((status !== 200 && status !== 201) && !errorHandled) {
            return handle(context, $xhr);
          }
        });
      }
    };
  });

}).call(this);

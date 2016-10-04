(function() {
  define(function(require) {
    var Chaplin, ROOT_DOMAIN_REGEX, handle, handle401, handle403, handleAny, parseResponse, publishError, resolveMessage, setupErrorHandling, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    ROOT_DOMAIN_REGEX = /^(?:https?:)?(?:\/\/)?([^\/\?]+)/mig;
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
    publishError = function(message) {
      return Chaplin.EventBroker.publishEvent('notify', message, {
        classes: 'alert-danger'
      });
    };

    /**
     * Session expired handler.
     */
    handle401 = function($xhr, options) {
      var match, ref, response, url;
      if (options == null) {
        options = {};
      }
      response = parseResponse($xhr);
      if (url = response != null ? response.redirect_url : void 0) {
        if (match = (ref = options.url) != null ? ref.match(ROOT_DOMAIN_REGEX) : void 0) {
          utils.setLocation(utils.urlJoin(match[0], url) + ("?destination=" + (utils.getLocation())));
        } else {
          utils.setLocation(url);
        }
      } else {
        utils.reloadLocation();
      }
      return $xhr.errorHandled = true;
    };

    /**
     * Access denied handler.
     */
    handle403 = function($xhr) {
      var message, response;
      response = parseResponse($xhr);
      utils.redirectTo({});
      message = resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.no_access') : void 0) || "Sorry, you don't have access to that section of the application.";
      publishError(message);
      return $xhr.errorHandled = true;
    };

    /**
     * Any error handler.
     */
    handleAny = function($xhr) {
      var message, response;
      response = parseResponse($xhr);
      message = resolveMessage(response) || (typeof I18n !== "undefined" && I18n !== null ? I18n.t('error.notification') : void 0) || 'There was a problem communicating with the server.';
      publishError(message);
      return $xhr.errorHandled = true;
    };

    /**
     * Generic error handler.
     */
    handle = function($xhr) {
      var ref;
      if ($xhr.status === 401) {
        return handle401.apply(this, arguments);
      } else if (!$xhr.errorHandled) {
        if ($xhr.status === 403) {
          return handle403.apply(this, arguments);
        } else if ((ref = $xhr.status) !== 200 && ref !== 201) {
          return handleAny.apply(this, arguments);
        }
      }
    };

    /**
     * Setups global error listeners.
     */
    setupErrorHandling = function() {
      return $(document).ajaxError(function(event, $xhr, options) {
        return handle($xhr, options);
      });
    };

    /**
     * This is meant to be used in the application bootstrapping code such as
     * application.coffee where invoking it in an init block will attach itself
     * once globally.
     */
    return {
      handle401: handle401,
      handle403: handle403,
      handleAny: handleAny,
      handle: handle,
      setupErrorHandling: setupErrorHandling
    };
  });

}).call(this);

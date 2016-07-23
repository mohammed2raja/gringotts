# This is meant to be used in the application bootstrapping code such as
# application.coffee where invoking it in an init block will attach itself once
# globally.
define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'

  parseResponse = ($xhr) ->
    try
      return utils.parseJSON $xhr.responseText
    catch
      return null

  resolveMessage = (response) ->
    response?.error or response?.message

  ##
  # Session Expired handler
  ##
  handle401 = (context, $xhr) ->
    # Since the session is now expired reloading a page will trigger an
    # auth check and bounce the user to the login page. Because of that
    # after they successfully log back in they should be redirected back
    # here.
    (context or window).location.reload()

  ##
  # Access Denied handler
  ##
  handle403 = (context, $xhr) ->
    response = parseResponse $xhr
    utils.redirectTo {}
    message = resolveMessage(response) or
      I18n?.t('error.no_access') or
      "Sorry, you don't have access to that section of the application."
    (context or Chaplin.EventBroker).publishEvent 'notify',
      message, classes: 'alert-danger'
    $xhr.errorHandled = true

  ##
  # Generic error handler
  ##
  handle = (context, $xhr) ->
    response = parseResponse $xhr
    message = resolveMessage(response) or
      I18n?.t('error.notification') or
      'There was a problem communicating with the server.'
    (context or Chaplin.EventBroker).publishEvent 'notify', message,
      classes: 'alert-danger'
    $xhr.errorHandled = true

  setupErrorHandling: (context) ->
    $(document).ajaxError (event, $xhr) ->
      {status, errorHandled} = $xhr
      if status is 401 then handle401 context, $xhr
      else if status is 403 and not errorHandled then handle403 context, $xhr
      else if status not in [200, 201] and not errorHandled
        handle context, $xhr

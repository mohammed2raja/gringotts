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

  publishError = (message) ->
    Chaplin.EventBroker.publishEvent 'notify',
      message, classes: 'alert-danger'

  ###*
   * Session expired handler.
  ###
  handle401 = ($xhr) ->
    response = parseResponse $xhr
    if url = response?.redirect_url
      utils.setLocation url
    else
      # Since the session is now expired reloading a page will trigger an
      # auth check and bounce the user to the login page. Because of that
      # after they successfully log back in they should be redirected back
      # here.
      utils.reloadLocation()
    $xhr.errorHandled = true

  ###*
   * Access denied handler.
  ###
  handle403 = ($xhr) ->
    response = parseResponse $xhr
    utils.redirectTo {}
    message = resolveMessage(response) or
      I18n?.t('error.no_access') or
      "Sorry, you don't have access to that section of the application."
    publishError message
    $xhr.errorHandled = true

  ###*
   * Any error handler.
  ###
  handleAny = ($xhr) ->
    response = parseResponse $xhr
    message = resolveMessage(response) or
      I18n?.t('error.notification') or
      'There was a problem communicating with the server.'
    publishError message
    $xhr.errorHandled = true

  ###*
   * Generic error handler.
  ###
  handle = ($xhr) ->
    if $xhr.status is 401 then handle401 $xhr
    else if $xhr.status is 403 then handle403 $xhr
    else if $xhr.status not in [200, 201] then handleAny $xhr

  ###*
   * Setups global error listeners.
  ###
  setupErrorHandling = ->
    $(document).ajaxError (event, $xhr) ->
      handle $xhr unless $xhr.errorHandled

  ###*
   * This is meant to be used in the application bootstrapping code such as
   * application.coffee where invoking it in an init block will attach itself
   * once globally.
  ###
  {handle401, handle403, handleAny, handle, setupErrorHandling}

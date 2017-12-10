utils = require 'lib/utils'
helper = require '../../lib/mixin-helper'
Notifying = require './notifying'

parseResponse = ($xhr) ->
  try
    return utils.parseJSON $xhr.responseText
  catch
    return null

resolveMessage = (response) ->
  response?.error or response?.message

module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class ErrorHandling extends Notifying superclass
  helper.setTypeName @prototype, 'ErrorHandling'

  listen:
    'promise-error model': (m, e) -> @handleError e
    'promise-error collection': (m, e) -> @handleError e

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...
    @handleError = @handleError.bind this

  ###*
    * Generic error handler. Works with an Error and XHR instances.
  ###
  handleError: (obj) ->
    if obj.status?
      $xhr = obj
      if $xhr.statusText is 'abort'
        @markAsHandled $xhr
      else if $xhr.status not in [200, 201]
        @handleAny $xhr
    else
      @logError obj
      @markAsHandled obj

  ###*
    * Any XHR error handler.
  ###
  handleAny: ($xhr) ->
    response = parseResponse $xhr
    message = resolveMessage(response) or @genericErrorMessage()
    @notifyError message
    @markAsHandled $xhr

  genericErrorMessage: ->
    I18n?.t('error.notification') or
    'There was a problem communicating with the server.'

  logError: (obj) ->
    return unless window.console and window.console.warn
    window.console.warn obj

  markAsHandled: (obj) ->
    obj.errorHandled = yes

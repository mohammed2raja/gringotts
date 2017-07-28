helper = require '../../lib/mixin-helper'

module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class ErrorHandled extends superclass
  helper.setTypeName @prototype, 'ErrorHandled'

  initialize: ->
    helper.assertModelOrCollection this
    super

  ###*
    * Generic error handler. Works with an Error and XHR instances.
    * It triggers the event that a related view with applied ErrorHandling
    * mixin will consume.
  ###
  handleError: (obj) =>
    @trigger 'promise-error', this, obj
    @logError(obj) unless obj.errorHandled

  logError: (obj) ->
    return unless window.console and window.console.warn
    window.console.warn 'Warning, an error was not handled correctly'
    if obj.status
      window.console.warn 'HTTP Error', obj.status, obj
    else
      window.console.warn obj

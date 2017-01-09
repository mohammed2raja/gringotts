define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'

  ###*
   * Sets XHR errors on fetch as handled,
   * to suppress further error notification.
   * This mixin is useful for Collections that are being used by views
   * with ServiceErrorReady applied.
  ###
  (superclass) -> class ServiceErrorHandled extends superclass
    helper.setTypeName @prototype, 'ServiceErrorHandled'

    initialize: ->
      helper.assertCollection this
      helper.assertNotModel this
      super

    fetch: ->
      utils.abortable super, catch: ->

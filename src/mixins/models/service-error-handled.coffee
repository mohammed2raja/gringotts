define (require) ->
  helper = require '../../lib/mixin-helper'

  ###*
   * Sets all XHR errors as handled, to suppress global error notification.
  ###
  (superclass) -> class ServiceErrorHandled extends superclass
    helper.setTypeName @prototype, 'ServiceErrorHandled'

    initialize: ->
      helper.assertModelOrCollection this
      super

    sync: (method, model, options={}) ->
      error = options.error
      # suppress global error handler
      options.error = ($xhr) ->
        $xhr.errorHandled = true
        error?.apply this, arguments
      super

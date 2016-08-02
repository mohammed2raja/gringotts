define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'

  # Allow the view to redirect to a specified `route` when a model's
  # request results in a `403` or `404`. A `notify` event will be
  # published.
  #
  # Specify a `route` key in `badModelOpts` to declare the route to redirect to
  # and specify a `message` to be passed with the event. If it's a function,
  # the first argument will be the model.
  (superclass) -> class BadModel extends superclass
    helper.setTypeName @prototype, 'BadModel'

    badModelOpts: {}
    listen:
      'error model': (model, $xhr) ->
        {message, route} = @badModelOpts
        if $xhr.status in [403, 404]
          message = message?(model) or message or
            "The model #{model.id} could not be accessed."
          # Allow for multiple arguments to be passed in if route returns array
          args = route?(model) or route or ''
          args = [args] unless _.isArray args
          utils.redirectTo.apply utils, args
          @publishEvent 'notify', message, classes: 'alert-danger'
          $xhr.errorHandled = true

    initialize: ->
      helper.assertViewOrCollectionView this
      super

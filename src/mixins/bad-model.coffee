# Allow the view to redirect to a specified `route` when a model's
# request results in a `403` or `404`. A `notify` event will be
# published. You can pass in options for the event with `evtOpts`
# key in `opts` where `classes` and `reqTimeout` have defaults.
#
# Specify a `route` key in `opts` to declare the route to redirect to
# and specify a `message` to be passed with the event. If it's a function,
# the first argument will be the model.
define (require) ->
  _ = require 'underscore'
  utils = require '../lib/utils'
  advice = require 'flight/advice'

  DEFAULTS =
    classes: 'alert-danger'
    reqTimeout: 10000

  (opts={}) ->
    # 'Extend' the `listen` hash, even if it's not present, without
    # having this handler overridden if the hash is declared later.
    @before 'delegateListeners', ->
      # Setup configuration here for callback to access correct properties.
      {message} = opts
      route = opts.route or ''

      evtOpts =
        if opts.evtOpts
          _.defaults opts.evtOpts, DEFAULTS
        else
          DEFAULTS

      @delegateListener 'error', 'model', (model, $xhr) ->
        {id} = model
        {status} = $xhr
        if status in [400, 403, 404]
          message = message model if typeof message is 'function'
          message ||= "The model #{id} could not be accessed."
          # Allow for multiple arguments to be passed in if route returns array
          args = route?(model) or route
          args = [args] unless _.isArray args
          utils.redirectTo.apply utils, args
          # NOTE: This cannot be sticky because it triggers before navigation!
          @publishEvent 'notify', message, evtOpts
          $xhr.errorHandled = true

    this

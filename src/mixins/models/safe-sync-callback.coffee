define (require) ->
  helper = require '../../lib/mixin-helper'

  # This mixin prevent errors when sync/fetch callback executes after
  # route change when model is disposed. It should be called in sync method.
  (superclass) -> class SafeSyncCallback extends superclass
    helper.setTypeName @prototype, 'SafeSyncCallback'

    initialize: ->
      helper.assertModelOrCollection this
      super

    sync: ->
      @safeSyncCallback.apply this, arguments
      @safeDeferred super

    # Piggies back off the AJAX option hash which the Backbone
    # server methods (such as `fetch` and `save`) use.
    safeSyncCallback: (method, model, options) ->
      return unless options
      _.each ['success', 'error', 'complete'], (cb) =>
        callback = options[cb]
        if callback
          ctx = options.context or this
          options[cb] = =>
            # Check disposal at time of use.
            callback.apply ctx, arguments unless @disposed

    # Filters deferred calbacks and cancels chain if model is disposed
    safeDeferred: ($xhr) ->
      return unless $xhr
      filter = =>
        if @disposed
          $xhr.errorHandled = true # suppress all error notifications
          $.Deferred()
        else $xhr
      # doneFilter, failFilter, progressFilter
      deferred = $xhr.then(filter, filter, filter).promise()
      deferred.abort = -> $xhr.abort() # compatibility with ajax deferred
      deferred

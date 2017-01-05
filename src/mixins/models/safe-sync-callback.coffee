define (require) ->
  helper = require '../../lib/mixin-helper'

  ###*
   * This mixin prevent errors when sync/fetch callback executes after
   # route change when model is disposed.
  ###
  (superclass) -> class SafeSyncCallback extends superclass
    helper.setTypeName @prototype, 'SafeSyncCallback'

    initialize: ->
      helper.assertModelOrCollection this
      super

    sync: ->
      @safeSyncHashCallbacks.apply this, arguments
      @safeSyncPromiseCallbacks super

    ###*
     * Piggies back off the AJAX option hash which the Backbone
     # server methods (such as `fetch` and `save`) use.
    ###
    safeSyncHashCallbacks: (method, model, options) ->
      return unless options
      _.each ['success', 'error', 'complete'], (cb) =>
        callback = options[cb]
        if callback
          ctx = options.context or this
          options[cb] = =>
            # Check disposal at time of use.
            callback.apply ctx, arguments unless @disposed

    ###*
     * Filters deferred calbacks and cancels chain if model is disposed.
    ###
    safeSyncPromiseCallbacks: ($xhr) ->
      return unless $xhr
      filter = =>
        if @disposed
          $xhr.errorHandled = true # suppress all error notifications
          @safeSyncDeadPromise()
        else $xhr
      # doneFilter, failFilter, progressFilter
      deferred = $xhr.then(filter, filter, filter).promise()
      deferred.abort = -> $xhr.abort() # compatibility with ajax deferred
      deferred

    ###*
     * A promise that never resolved, so niether of callbacks is called.
    ###
    safeSyncDeadPromise: ->
      $.Deferred().promise()

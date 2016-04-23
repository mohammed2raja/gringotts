define (require) ->
  # This mixin alerts the user when APIs are down via a `notify` event through
  # `publishEvent`. It should be called in sync method.
  # A `service-unavailable` event is triggered on the model/collection as well.
  (superclass) -> class ServiceErrorCallback extends superclass
    sync: ->
      @serviceErrorCallback.apply this, arguments
      super

    serviceErrorCallback: (method, model, options) ->
      return unless options
      callback = options.error
      options.error = ($xhr) =>
        # Don't trigger for canceled requests.
        if $xhr.statusText isnt 'abort' or $xhr.statusText is 'error'
          ctx = options.context or this
          callback?.apply ctx, arguments
          @abortSync?() # Removes loading indicators present.
          # `trigger` is a safe operation even if disposed.
          @trigger 'service-unavailable'
          $xhr.errorHandled = true

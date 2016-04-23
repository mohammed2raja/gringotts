define (require) ->
  # Display errors when a collection sync returns an error.
  # This follows a similar pattern to the `loadingSelector`
  # and `fallbackSelector` that `Chaplin.CollectionView` provides.
  #
  # Works with the event emitted by the `service-unavailable` mixin.
  (superclass) -> class ServiceErrorReady extends superclass
    errorSelector: '.service-error'
    listen:
      # Triggers as a result of a request.
      'service-unavailable collection': -> @$(@errorSelector).show()
      # Reset error messages on subsequent requests.
      'syncStateChange collection': -> @$(@errorSelector).hide()

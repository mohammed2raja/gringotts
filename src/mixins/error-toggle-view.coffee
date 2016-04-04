# Display errors when a collection sync returns an error.
# This follows a similar pattern to the `loadingSelector`
# and `fallbackSelector` that `Chaplin.CollectionView` provides.
#
# Works with the event emitted by the `service-unavailable` mixin.
define (require) ->
  (superclass) -> class ErrorToggleView extends superclass

    listen:
      # Triggers as a result of a request.
      'service-unavailable collection': -> @$(@_errorSelector()).show()

      # Reset error messages on subsequent requests.
      'syncStateChange collection': -> @$(@_errorSelector()).hide()

    _errorSelector: -> @errorSelector or '.service-error'

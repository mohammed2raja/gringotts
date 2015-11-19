# Display errors when a collection sync returns an error.
# This follows a similar pattern to the `loadingSelector`
# and `fallbackSelector` that `Chaplin.CollectionView` provides.
#
# Works with the event emitted by the `service-unavailable` mixin.
define (require) ->

  ->
    # 'Extend' the `listen` hash, even if it's not present, without
    # having this handler overridden if the hash is declared later.
    @before 'delegateListeners', ->
      selector = @errorSelector or '.service-error'
      # Triggers as a result of a request.
      @delegateListener 'service-unavailable', 'collection', ->
        @$(selector).show()
      # Reset error messages on subsequent requests.
      @delegateListener 'syncStateChange', 'collection', ->
        @$(selector).hide()

    this

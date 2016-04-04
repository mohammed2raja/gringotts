define (require) ->
  (superclass) -> class OverrideXHR extends superclass
    fetch: ->
      @overrideXHR super

    ###*
     * Aborts the existing request if a new one is being requested.
    ###
    overrideXHR: ($xhr) ->
      @currentXHR.abort?() if @currentXHR and @isSyncing()
      @currentXHR = $xhr

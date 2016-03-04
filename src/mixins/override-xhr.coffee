define (require) ->
  ###*
   * Aborts the existing request if a new one is being requested.
  ###
  overrideXHR: (promise) ->
    @currentXHR.abort() if @currentXHR and @isSyncing()
    @currentXHR = promise

define (require) ->
  ###*
   * Aborts the existing fetch request if a new one is being requested.
  ###
  (superclass) -> class Abortable extends superclass
    initialize: ->
      super
      unless _.isFunction @isSyncing
        throw new Error 'Abortable mixin works only with ActiveSyncMachine'

    fetch: ->
      $xhr = super
      @_currentXHR.abort?() if @_currentXHR and @isSyncing()
      @_currentXHR = if $xhr then $xhr.always => delete @_currentXHR

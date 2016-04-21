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
      if @currentXHR and _.isFunction(@currentXHR.abort) and @isSyncing()
        @currentXHR
          # muting the ajax error raised during abort
          .fail ($xhr) -> $xhr.errorHandled = true if $xhr.status is 0
          .abort()
      @currentXHR = if $xhr then $xhr.always => delete @currentXHR

define (require) ->

  ###*
   * Creates a promise that is never resolved, so niether of chain callbacks
   * is called. This is useful for mocking in unit testing.
  ###
  create: ->
    $.Deferred().promise()

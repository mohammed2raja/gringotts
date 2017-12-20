export default {
  ###*
   * Creates a promise that is never resolved. This prevents either
   * chain of callbacks from executing. This is useful for mocking
   * in unit tests.
  ###
  create: ->
    $.Deferred().promise()
}

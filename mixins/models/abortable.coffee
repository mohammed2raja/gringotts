utils = require 'lib/utils'
helper = require '../../lib/mixin-helper'

###*
  * Aborts the existing fetch request if a new one is being requested.
###
module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class Abortable extends superclass
  helper.setTypeName @prototype, 'Abortable'

  initialize: ->
    helper.assertModelOrCollection this
    super

  fetch: ->
    @current_fetch.abort() if @current_fetch
    @current_fetch = utils.abortable super,
      then: (r, s, $xhr) =>
        delete @current_fetch; $xhr

  sync: (method, model, options={}) ->
    error = options.error
    options.error = ($xhr) ->
      # cancel default error handler for abort errors
      unless $xhr.statusText is 'abort'
        error?.apply this, arguments
    super

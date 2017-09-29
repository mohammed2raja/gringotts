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
    @makeAbortable 'fetch', super

  sync: (method, model, options={}) ->
    error = options.error
    options.error = ($xhr) ->
      # cancel default error handler for abort errors
      unless $xhr.statusText is 'abort'
        error?.apply this, arguments
    super

  makeAbortable: (methodName, superMethod) ->
    current_method = "current_#{methodName}"
    @[current_method].abort() if @[current_method]
    @[current_method] = utils.abortable superMethod,
      then: (r, s, $xhr) =>
        delete @[current_method]; $xhr

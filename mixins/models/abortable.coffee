import utils from 'lib/utils'
import helper from '../../lib/mixin-helper'

###*
  * Aborts the existing fetch request if a new one is being requested.
###
export default (superclass) -> helper.apply superclass, (superclass) -> \

class Abortable extends superclass
  helper.setTypeName @prototype, 'Abortable'

  initialize: ->
    helper.assertModelOrCollection this
    super arguments...

  fetch: ->
    @makeAbortable 'fetch', super arguments...

  sync: (method, model, options={}) ->
    error = options.error
    options.error = ($xhr) ->
      # cancel default error handler for abort errors
      unless $xhr.statusText is 'abort'
        error?.apply this, arguments
    super arguments...

  makeAbortable: (methodName, promise) ->
    current_method = "current_#{methodName}"
    @[current_method]?.abort()
    @[current_method] = utils.abortable promise,
      then: (r, s, $xhr) =>
        delete @[current_method] unless @disposed
        $xhr

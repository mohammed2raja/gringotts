import {disposable} from '../../lib/utils'
import helper from '../../lib/mixin-helper'

###*
  * This mixin prevent errors when sync/fetch callback executes after
  # route change when model is disposed.
###
export default (superclass) -> helper.apply superclass, (superclass) -> \

class SafeSyncCallback extends superclass
  helper.setTypeName @prototype, 'SafeSyncCallback'

  initialize: ->
    helper.assertModelOrCollection this
    super arguments...

  sync: ->
    @safeSyncHashCallbacks.apply this, arguments
    disposable super(arguments...), => @disposed

  ###*
    * Piggies back off the AJAX option hash which the Backbone
    # server methods (such as `fetch` and `save`) use.
  ###
  safeSyncHashCallbacks: (method, model, options) ->
    return unless options
    _.each ['success', 'error', 'complete'], (cb) =>
      callback = options[cb]
      if callback
        ctx = options.context or this
        options[cb] = (args...) =>
          # Check disposal at time of use.
          callback.apply ctx, args unless @disposed

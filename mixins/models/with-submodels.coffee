import utils from 'lib/utils'
import helper from '../../lib/mixin-helper'
import Collection from 'models/base/collection'

###*
  * Manages sub-model updates
###
export default (superclass) -> class WithSubmodels extends superclass
  SUB_MODELS: null

  initialize: ->
    helper.assertModel this
    super arguments...
    unless @SUB_MODELS
      throw new Error 'SUB_MODELS is required'
    @initSubmodels.apply this, arguments
    @initSubmodelsListeners()

  initSubmodels: ->

  ###*
    * Binds submodels to model changes
  ###
  initSubmodelsListeners: (opts = {}) ->
    @submodels = _.map @SUB_MODELS, (sm) => @[sm]
    _.forEach @SUB_MODELS, (sm) =>
      @on "change:#{sm}", (m, v) -> @onChangeForSubmodels @[sm], v, opts
    @on 'request', -> _.invokeMap @submodels, 'beginSync'
    @on 'error', -> _.invokeMap @submodels, 'unsync'

  ###*
    * Updates submodels
  ###
  onChangeForSubmodels: (obj, value, opts) ->
    if obj instanceof Collection
      obj.reset value, {parse: yes}
    else
      obj.set value, {parse: yes}
    obj.finishSync()

  dispose: ->
    _.invokeMap @submodels, 'dispose'
    super arguments...

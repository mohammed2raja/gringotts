define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  ForcedReset = require './forced-reset'
  StatefulUrlParams = require './stateful-url-params'

  ###*
   * Adds sorting support to a Collection. It relies on StatefulUrlParams
   * mixin to persist sorting state and add to url query params on every
   * sync action.
   * @param  {Collection} base superclass
  ###
  (base) -> class Sorted extends utils.mix(base).with(StatefulUrlParams,
    ForcedReset)
    helper.setTypeName @prototype, 'Sorted'

    DEFAULTS: _.extend {}, @::DEFAULTS,
      order: 'desc'
      sort_by: undefined

    initialize: ->
      helper.assertCollection this
      super

define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  ForcedReset = require './forced-reset'
  Queryable = require './queryable'

  ###*
   * Adds sorting support to a Collection. It relies on Queryable
   * mixin to persist sorting query state and add it to url query params
   * on every sync action.
   * @param  {Collection} base superclass
  ###
  (base) -> class Sorted extends utils.mix(base).with Queryable, ForcedReset
    helper.setTypeName @prototype, 'Sorted'

    DEFAULTS: _.extend {}, @::DEFAULTS,
      order: 'desc'
      sort_by: undefined

    initialize: ->
      helper.assertCollection this
      super

    fetch: ->
      @reset() # remove existing items
      super

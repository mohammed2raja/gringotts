define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  StatefulUrlParams = require './stateful-url-params'
  SyncKey = require './sync-key'

  ###*
   * Adds pagination support to a Collection. It relies on StatefulUrlParams
   * mixin to persist pagination state and add to url query params on every
   * sync action.
   * @param  {Collection} base superclass
  ###
  (base) -> class Paginated extends utils.mix(base).with(StatefulUrlParams,
    SyncKey)
    helper.setTypeName @prototype, 'Paginated'

    DEFAULTS: _.extend {}, @::DEFAULTS,
      page: 1
      per_page: 30

    ###*
     * Sets the pagination mode for collection.
     * @type {Boolean} True if infitine, false otherwise
    ###
    infinite: false

    initialize: ->
      helper.assertCollection this
      super
      @on 'remove', -> @count = Math.max 0, (@count or 1) - 1

    parse: (resp) ->
      result = super
      @nextPageId = resp.next_page_id if @infinite
      result

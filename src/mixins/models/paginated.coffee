define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  ForcedReset = require './forced-reset'
  Queryable = require './queryable'
  SyncKey = require './sync-key'

  ###*
   * Adds pagination support to a Collection. It relies on Queryable
   * mixin to persist pagination query state and add it to url query params
   * on every sync action.
   * @param  {Collection} base superclass
  ###
  (base) -> class Paginated extends utils.mix(base).with(Queryable,
    ForcedReset, SyncKey)
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

    fetch: ->
      @reset() # remove existing items
      super?.fail => @count = 0

    parse: (resp) ->
      result = super
      @count = parseInt resp.count
      @nextPageId = resp.next_page_id if @infinite
      result

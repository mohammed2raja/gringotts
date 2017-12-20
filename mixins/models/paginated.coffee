import utils from 'lib/utils'
import helper from '../../lib/mixin-helper'
import SafeSyncCallback from './safe-sync-callback'
import ForcedReset from './forced-reset'
import Queryable from './queryable'
import SyncKey from './sync-key'

###*
  * Adds pagination support to a Collection. It relies on Queryable
  * mixin to persist pagination query state and add it to url query params
  * on every sync action.
  * @param  {Collection} base superclass
###
export default (superclass) -> helper.apply superclass, (superclass) -> \

class Paginated extends Queryable ForcedReset SyncKey \
    SafeSyncCallback superclass
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
    super arguments...

  fetch: ->
    @reset() # remove existing items
    utils.abortable super(arguments...), catch: ($xhr) =>
      @count = 0 unless $xhr.statusText is 'abort'; $xhr

  parse: (resp) ->
    result = super arguments...
    @count = parseInt resp.count
    @nextPageId = resp.next_page_id if @infinite
    result

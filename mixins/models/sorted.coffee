import helper from '../../lib/mixin-helper'
import SafeSyncCallback from './safe-sync-callback'
import ForcedReset from './forced-reset'
import Queryable from './queryable'

###*
  * Adds sorting support to a Collection. It relies on Queryable
  * mixin to persist sorting query state and add it to url query params
  * on every sync action.
  * @param  {Collection} base superclass
###
export default (superclass) -> helper.apply superclass, (superclass) -> \

class Sorted extends Queryable ForcedReset SafeSyncCallback superclass
  helper.setTypeName @prototype, 'Sorted'

  DEFAULTS: _.extend {}, @::DEFAULTS,
    order: 'desc'
    sort_by: undefined

  initialize: ->
    helper.assertCollection this
    super arguments...

  fetch: ->
    @reset() # remove existing items
    super arguments...

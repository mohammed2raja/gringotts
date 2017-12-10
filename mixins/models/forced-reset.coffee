utils = require 'lib/utils'
helper = require '../../lib/mixin-helper'
SafeSyncCallback = require './safe-sync-callback'

###*
  * Forces reseting all models in collection upon failed ajax request.
  * This is required for Sorted or Paginated collections,
  * to clear current items if new page request or new sort ajax request failed.
###
module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class ForcedReset extends SafeSyncCallback superclass
  helper.setTypeName @prototype, 'ForcedReset'

  initialize: ->
    helper.assertCollection this
    helper.assertNotModel this
    super arguments...

  fetch: ->
    utils.abortable super(arguments...), catch: ($xhr) => @reset(); $xhr

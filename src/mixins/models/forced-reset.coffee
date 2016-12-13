define (require) ->
  helper = require '../../lib/mixin-helper'

  ###*
   * Forces reseting all models in collection upon failed ajax request.
   * This is required for Sorted or Paginated collections,
   * to clear current items if new page request or new sort ajax request failed.
  ###
  (base) -> class ForcedReset extends base
    helper.setTypeName @prototype, 'ForcedReset'

    initialize: ->
      helper.assertCollection this
      helper.assertNotModel this
      super

    fetch: ->
      super?.fail => @reset()

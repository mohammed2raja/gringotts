define (require) ->
  helper = require '../../lib/mixin-helper'

  ###*
   * Checks response JSON on every fetch and extracts items stored in "syncKey"
   * property name. Most of the time it's used for so call responses with
   * metadata. When you need to pass from server set of items and extra info
   * like total elements count or next page id. Example:
   * {
   *   count: 55
   *   description: "Some elements from server"
   *   elements: [
   *     {id: 0}
   *     {id: 1}
   *   ]
   * }
   * @param  {Collection}  superclass
  ###
  (superclass) -> class SyncKey extends superclass
    helper.setTypeName @prototype, 'SyncKey'

    ###*
     * Name of the property in response JSON that carries an array of items.
     * @type {String}
    ###
    syncKey: null

    initialize: ->
      helper.assertCollection this
      super

    parse: ->
      result = super
      if @syncKey then result[@syncKey] else result

import helper from '../../lib/mixin-helper'

###*
  * Checks a response after every fetch and extracts items in "syncKey"
  * attribute. It is helpful when a server adds extra info like total
  * elements count or next page ID into a response.
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
export default (superclass) -> helper.apply superclass, (superclass) -> \

class SyncKey extends superclass
  helper.setTypeName @prototype, 'SyncKey'

  ###*
    * Name of the property in response JSON that carries an array of items.
    * @type {String|Function}
  ###
  syncKey: null

  initialize: ->
    helper.assertCollection this
    super arguments...

  parse: ->
    result = super arguments...
    if @syncKey then result[_.result this, 'syncKey'] else result

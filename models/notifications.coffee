import Model from './base/model'
import Collection from './base/collection'

class Notification extends Model
  idAttribute: 'message'


# An observer class for notifications. It makes sure that same messages
# are not duplicated in the collection.
export default class Notifications extends Collection
  listenGlobal: false
  model: Notification

  initialize: (models, opts) ->
    super arguments...
    @listenGlobal = opts.listenGlobal if opts?.listenGlobal
    if @listenGlobal
      @subscribeEvent 'notify', @addMessage
      @subscribeEvent 'denotify', @removeMessage

  addMessage: (message, opts) ->
    @removeMessage message, opts
    @add _.pickBy {message, opts}

  removeMessage: (message, opts) ->
    @remove _.filter @toJSON(), _.pickBy {message, opts}

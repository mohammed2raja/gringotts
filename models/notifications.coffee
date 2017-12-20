import Collection from './base/collection'

# An observer class for notifications. It makes sure that same messages
# are not duplicated in the collection.
export default class Notifications extends Collection
  listenGlobal: false

  initialize: (models, opts) ->
    super arguments...
    @listenGlobal = opts.listenGlobal if opts?.listenGlobal
    if @listenGlobal
      @subscribeEvent 'notify', @addMessage

  addMessage: (message, opts) ->
    @remove @where {message}
    @add {message, opts}

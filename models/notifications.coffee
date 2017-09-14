define (require) ->
  Collection = require './base/collection'

  # An observer class for notifications. It makes sure that same messages
  # are not duplicated in the collection.
  class Notifications extends Collection
    initialize: ->
      super
      @subscribeEvent 'notify', (message, opts) ->
        @remove @where {message}
        @add {message, opts}

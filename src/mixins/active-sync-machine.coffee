define (require) ->
  Chaplin = require 'chaplin'

  (superclass) -> class ActiveSyncMachine extends superclass
    _.extend @prototype, Chaplin.SyncMachine

    initialize: ->
      super
      @activateSyncMachine()

    ###*
     * Activates Chaplin.SyncMachine on an object
     * @param  {Backbone.Events} obj an instinace of Model or Collection
     * @param  {Bool} listenAll to listen events from nested models
    ###
    activateSyncMachine: (listenAll=false) ->
      throw new Error('obj must have Backbone.Events mixed-in') unless @on
      _.each [
          {event: 'request', listener: 'beginSync'}
          {event: 'sync', listener: 'finishSync'}
          {event: 'error', listener: 'unsync'}
        ], (map) ->
          @on map.event, (model) ->
            @[map.listener]() if this is model or listenAll
      , this

define (require) ->
  Chaplin = require 'chaplin'
  helper = require '../../lib/mixin-helper'

  EVENT_MAP = [
    {event: 'request', method: 'beginSync'}
    {event: 'sync', method: 'finishSync'}
    {event: 'error', method: 'unsync'}
  ]

  STATE_MAP =
    syncing: 'beginSync'
    synced: 'finishSync'
    unsynced: 'unsync'

  switchStateTo = (target, state) ->
    target[STATE_MAP[state]]()

  (superclass) -> class ActiveSyncMachine extends superclass
    _.extend @prototype, Chaplin.SyncMachine
    helper.setTypeName @prototype, 'ActiveSyncMachine'


    initialize: ->
      helper.assertModelOrCollection this
      super
      @activateSyncMachine()

    ###*
     * Activates SyncMachine on current model or collection.
    ###
    activateSyncMachine: ->
      @bindSyncMachineTo this

    ###*
     * Binds current model SyncMachine to a source model.
     * @param  {Model|Collection}   source
     * @param  {Object}             options, listenAll: true to listen events
     *                                       from nested models
    ###
    bindSyncMachineTo: (source, options) ->
      options = _.defaults {}, options, listenAll: false
      _.each EVENT_MAP, (entry) =>
        @listenTo source, entry.event, (target) ->
          @[entry.method]() if target is source or options.listenAll

    ###*
     * Unbinds current model SyncMachine from a source model.
    ###
    unbindSyncMachineFrom: (source) ->
      _.each EVENT_MAP, (entry) =>
        @stopListening source, entry.event

    ###*
     * Links current model SyncMachine to another model SyncMachine.
     * @param  {Model|Collection} source  with SyncMachine.
    ###
    linkSyncMachineTo: (source) ->
      unless @syncState() is source.syncState()
        switchStateTo this, source.syncState()
      @listenTo source, 'syncStateChange', (source, state) ->
        switchStateTo this, state

    ###*
     * Unlinks current model SyncMachine from another model SyncMachine.
    ###
    unlinkSyncMachineFrom: (source) ->
      @stopListening source, 'syncStateChange'

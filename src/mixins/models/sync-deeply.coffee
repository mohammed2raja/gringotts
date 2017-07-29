define (require) ->
  Backbone = require 'backbone'
  helper = require '../../lib/mixin-helper'
  ActiveSyncMachine = require '../../mixins/models/active-sync-machine'

  isPerhapsSynced = (collection) ->
    if _.isFunction collection?.isSynced then collection.isSynced() else yes

  class ShadowSyncMachine extends ActiveSyncMachine (->)
    _.extend @prototype, Backbone.Events

  ###*
   * Helps synchronize sync state of a collection and it's children collections.
   * This mixin works the best when applied to Collections that serve as a
   * filter groups source of the FilterInputView control.
  ###
  (superclass) -> class SyncDeeply extends ActiveSyncMachine superclass
    helper.setTypeName @prototype, 'SyncDeeply'

    initialize: ->
      helper.assertCollection this
      super
      @unbindSyncMachineFrom this
      @shadowSyncMachine = new ShadowSyncMachine()
      @shadowSyncMachine.bindSyncMachineTo this
      @addDeepListener @shadowSyncMachine
      @on 'add', (model) -> @addDeepListener model.get 'children'
      @on 'remove', (model) -> @removeDeepListener model.get 'children'

    reset: ->
      super
      @each (model) => @addDeepListener model.get 'children'

    fetchChildren: ->
      $.when.apply this, @reduce (promises, model) ->
        if _.result (children = model.get 'children'), 'url'
          promises.push children.fetch()
        promises
      , []

    isSynced: ->
      @shadowSyncMachine.isSynced() and @reduce (synced, model) ->
        synced and isPerhapsSynced model.get 'children'
      , true

    addDeepListener: (collection) ->
      collection?.on 'syncStateChange', @onDeepSyncStateChange

    removeDeepListener: (collection) ->
      collection?.off 'syncStateChange', @onDeepSyncStateChange

    onDeepSyncStateChange: (collection, syncState) =>
      if syncState is 'syncing' and not @errorHappened
        @beginSync()
      else if syncState is 'synced' and @isSynced()
        @finishSync()
      else if syncState is 'unsynced'
        @errorHappened = yes
        @unsync()

    dispose: ->
      @removeDeepListener @shadowSyncMachine
      @each (model) =>
        @removeDeepListener model.get 'children'
      super

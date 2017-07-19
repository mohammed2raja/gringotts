define (require) ->
  helper = require '../../lib/mixin-helper'

  isPerhapsSynced = (collection) ->
    if _.isFunction collection?.isSynced then collection.isSynced() else yes

  ###*
   * Helps synchronize sync state of a collection and it's children collections.
   * This mixin works the best when applied to Collections that serve as a
   * filter groups source of the FilterInputView control.
  ###
  (superclass) -> class FilterGrouped extends superclass
    helper.setTypeName @prototype, 'FilterGrouped'

    initialize: ->
      helper.assertCollection this
      super
      @addSyncDeepListener this
      @on 'add', (model) -> @addSyncDeepListener model.get 'children'
      @on 'remove', (model) -> @removeSyncDeepListener model.get 'children'

    reset: ->
      super
      @each (model) =>
        @addSyncDeepListener model.get 'children'

    fetchChildren: ->
      $.when.apply this, @reduce (promises, model) ->
        if _.result (children = model.get 'children'), 'url'
          promises.push children.fetch()
        promises
      , []

    isSyncedDeep: ->
      isPerhapsSynced(this) and @reduce (synced, model) ->
        synced and isPerhapsSynced model.get 'children'
      , true

    addSyncDeepListener: (collection) ->
      collection?.on 'sync', @triggerSyncDeep

    removeSyncDeepListener: (collection) ->
      collection?.off 'sync', @triggerSyncDeep

    triggerSyncDeep: =>
      @trigger 'syncDeep', this if @isSyncedDeep()

    dispose: ->
      @each (model) ->
        model.get('children')?.dispose()
      super

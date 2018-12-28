import Chaplin from 'chaplin'
import helper from '../../lib/mixin-helper'

###*
  * Adds state model, that is a data source for state bindings.
  * Useful to distinguish data bindings that target default model,
  * and UI state bindings that target a special independent state model.
  * @param  {Backbone.View} superclass
###
export default (superclass) -> helper.apply superclass, (superclass) -> \

class StateBindable extends superclass
  helper.setTypeName @prototype, 'StateBindable'

  listen:
    'syncStateChange model': ->
      @state.set syncState: @model.syncState()

    'synced model': ->
      @updateModelHasChanges()

    'change model': ->
      @updateModelHasChanges()

    'syncStateChange collection': ->
      @state.set syncState: @collection.syncState()

    'synced collection': ->
      @updateCollectionHasChanges()

    'change collection': ->
      @updateCollectionHasChanges()

  ###*
    * Initial state of UI, that passed to state model.
    * The value could be either an object or a function.
    * @type {Object|Function}
  ###
  initialState: null

  ###*
    * A state model that servers as data source for state bindings.
    * @type {Backbone.Model}
  ###
  state: null

  ###*
    * UI state bindings to describe interactive UI with stickit bindings.
    * The value could be either an object or a function.
    * @type {Object|Function}
  ###
  stateBindings: null

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...
    attrs = _.result(this, 'initialState') or {}
    syncState = @model?.syncState?() or @collection?.syncState?()
    @state = new Chaplin.Model _.defaults attrs, {syncState}

  updateModelHasChanges: ->
    if @model.hasChanges
      @state.set hasChanges: @model.hasChanges()

  updateCollectionHasChanges: ->
    if @collection.hasChanges
      @state.set hasChanges: @collection.hasChanges()

  render: ->
    super()
    if @state and @stateBindings
      @addBinding @state, _.result this, 'stateBindings'

  dispose: ->
    super()
    @state.dispose()

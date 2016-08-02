define (require) ->
  Chaplin = require 'chaplin'
  helper = require '../../lib/mixin-helper'

  ###*
   * Adds state model, that is a data source for state bindings.
   * Useful to distinguish data bindings that target default model,
   * and UI state bindings that target a special independent state model.
   * @param  {Backbone.View} superclass
  ###
  (superclass) -> class StateBindable extends superclass
    helper.setTypeName @prototype, 'StateBindable'

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
      super
      @state = new Chaplin.Model _.result this, 'initialState'

    render: ->
      super
      if @state and @stateBindings
        @addBinding @state, _.result this, 'stateBindings'

    dispose: ->
      super
      @state.dispose()

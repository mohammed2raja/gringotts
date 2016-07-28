define (require) ->
  utils = require 'lib/utils'
  helper = require '../helper'

  ###*
   * A utility mixin for a View or a CollectionView. It helps to pass routing
   * parameters down the view hierarchy. Also adds helper methods to get current
   * browser query state (usually it's received from a Collection or a Model
   * with StatefulUrlParams mixin applied) or to redirect browser to current
   * route with updated query state.
   * The routeState is expected to be a StatefulUrlParams or it's proxy
   * with getState() method.
   * @param  {View|CollectionView} superclass
  ###
  (superclass) -> class Routing extends superclass
    ROUTING_OPTIONS: ['routeName', 'routeParams', 'routeState']
    optionNames: @::optionNames?.concat @::ROUTING_OPTIONS

    initialize: ->
      helper.assertViewOrCollectionView this
      super
      @routeState = (@collection or @model)?.proxyState?() unless @routeState

    ###*
     * Overrides Chaplin.CollectionView method to init sub items with
     * routing properties
     * @return {View}
    ###
    initItemView: ->
      view = super
      @ROUTING_OPTIONS.forEach (key) => view[key] = @[key]
      view

    getTemplateData: ->
      _.extend super, {@routeName, @routeParams}

    ###*
     * A hash of current routing options.
     * @return {Object}
    ###
    routeOpts: ->
      _.reduce @ROUTING_OPTIONS, (result, key) =>
        result[key] = @[key]
        result
      , {}

    ###*
     * A hash of current routing options extended with other has.
     * @return {Object}
    ###
    routeOptsWith: (hash) ->
      _.extend @routeOpts(), hash

    ###*
     * Returns current state of the browser query relevant to the routeName.
     * @return {Object}
    ###
    getBrowserState: ->
      unless @routeState
        throw new Error "Can't get state since @routeState isn't set."
      @routeState.getState {}, inclDefaults: yes

    ###*
     * Redirect to current route with new query params.
     * @param {Object}
    ###
    setBrowserState: (state={}) ->
      unless @routeState
        throw new Error "Can't set browser state since @routeState isn't set."
      utils.redirectTo @routeName, @routeParams,
        query: @routeState.getState state

    dispose: ->
      @ROUTING_OPTIONS.forEach (key) =>
        delete @[key]
      super

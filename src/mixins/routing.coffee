define (require) ->
  utils = require 'lib/utils'

  ###*
   * A utility mixin for View or CollectionView. It helps to pass routing
   * parameters down the view hierarchy. Also adds helper methods to get current
   * browser query state (usually it's received from a Collection) or to
   * redirect browser to current route with updated query state.
   * The routeState is expected to be a Collection or it's proxy with getState()
   * method.
   * @param  {View|CollectionView} superclass Only views
  ###
  (superclass) -> class Routing extends superclass
    ROUTING_OPTIONS: ['routeName', 'routeParams', 'routeState']
    optionNames: @::optionNames.concat @::ROUTING_OPTIONS

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

    render: ->
      unless 'routeName'
        throw new Error "Can't render view when routeName isn't set"
      super

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
      @routeState.getState {}, inclDefaults: yes

    ###*
     * Redirect to current route with new query params.
     * @param {Object}
    ###
    setBrowserState: (state={}) ->
      utils.redirectTo @routeName, @routeParams,
        query: @routeState.getState state

    dispose: ->
      @ROUTING_OPTIONS.forEach (key) =>
        delete @[key]
      super

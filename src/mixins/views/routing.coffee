define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'

  ###*
   * A utility mixin for a View or a CollectionView. It helps to pass routing
   * parameters down the view hierarchy. Also adds helper methods to get current
   * browser query state (usually it's received from a Collection or a Model
   * with Queryable mixin applied) or to redirect browser to current
   * route with updated query state.
   * The routeQueryable is expected to be a Queryable or it's proxy
   * with getQuery() method.
   * @param  {View|CollectionView} superclass
  ###
  (superclass) -> class Routing extends superclass
    helper.setTypeName @prototype, 'Routing'

    ROUTING_OPTIONS: ['routeName', 'routeParams', 'routeQueryable']
    optionNames: @::optionNames?.concat @::ROUTING_OPTIONS

    initialize: ->
      helper.assertViewOrCollectionView this
      super
      unless @routeQueryable
        @routeQueryable = (@collection or @model)?.proxyQueryable?()
      if @routeQueryable?.trigger
        @listenTo @routeQueryable, 'queryChange', (info) ->
          unless @muteQueryChangeEvent
            @onBrowserQueryChange info.query, info.diff
          else
            delete @muteQueryChangeEvent

    ###*
     * Overrides Chaplin.CollectionView method to init sub items with
     * routing properties
     * @return {View}
    ###
    initItemView: ->
      _.extend super, @routeOpts()

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
     * Returns current query of the browser query relevant to the routeName.
     * @return {Object}
    ###
    getBrowserQuery: ->
      unless @routeQueryable
        throw new Error "Can't get query since @routeQueryable isn't set."
      @routeQueryable.getQuery inclDefaults: yes, usePrefix: no

    ###*
     * Redirect to current route with new query params.
     * @param {Object} query to build URL query params with.
    ###
    setBrowserQuery: (query={}, options) ->
      unless @routeQueryable
        throw new Error "Can't set browser query
          since @routeQueryable isn't set."
      unless @routeName
        throw new Error "Can't set browser query since @routeName isn't set."
      @muteQueryChangeEvent = true # we don't want handle our own query change
      utils.redirectTo @routeName, @routeParams,
        _.extend {}, options, query: @routeQueryable.getQuery overrides: query

    ###*
     * Override this method to add your logic upon browser query change.
     * @param  {Object} query   current browser query from URL query params.
     * @param  {Object} diff    difference object from previous query.
    ###
    onBrowserQueryChange: (query, diff) ->

    dispose: ->
      @ROUTING_OPTIONS.forEach (key) =>
        delete @[key]
      super

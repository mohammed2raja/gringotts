define (require) ->
  Chaplin = require 'chaplin'
  utils = require '../../lib/utils'
  ActiveSyncMachine = require '../../mixins/active-sync-machine'
  Abortable = require '../../mixins/abortable'
  SafeSyncCallback = require '../../mixins/safe-sync-callback'
  ServiceErrorCallback = require '../../mixins/service-error-callback'
  Model = require './model'

  # Abstract class for collections. Includes useful mixins by default.
  class Collection extends utils.mix Chaplin.Collection
      .with ActiveSyncMachine, Abortable
        , SafeSyncCallback, ServiceErrorCallback

    model: Model

    ###*
     * State of the data with relation to the server.
     * @type {Object}
    ###
    state: null

    ###*
     * Custom string keyword to scope input state keys. Useful if there is
     * a case of using two or more instances of CollectionView on one page.
     * @type {String}
    ###
    prefix: null

    ###*
     * Default queryparam object for this collection.
     * Must contain all possible querynewState.
     * Override when necessary.
    ###
    DEFAULTS:
      order: 'desc'
      q: undefined
      sort_by: undefined

    ###*
     * Used to map local property names to queryparam server attrs
     * Override when necessary.
    ###
    DEFAULTS_SERVER_MAP: {}

    initialize: ->
      unless typeof @url is 'function'
        throw new Error 'Please use urlRoot instead
          of url as a collection property'
      super
      @state = {}
      @on 'remove', -> @count = Math.max 0, (@count or 1) - 1

    ###*
     * Generates a state hash from the current state and given overrides.
     * @param  {Object} overrides={} Optional overrides
     * @param  {Object} opts={}      inclDefaults - adds default state
     *                               values into result, it is false by default.
     *                               usePrefix - adds prefix string into state
     *                               property key, it is true by default.
     * @return {Object}              Combined state
    ###
    getState: (overrides={}, opts={}) ->
      state = _.extend {}, @DEFAULTS, @state, overrides
      # make sure only local properties are being passed in
      unless _.isEmpty _.intersection _.keys(state)
          , _.keys @DEFAULTS_SERVER_MAP
        throw new Error 'Pass in only local state properties.'
      state = @stripEmptyOrDefault state, opts
      # add prefixes and include alien values if requested
      if @prefix and (not _.isBoolean(opts.usePrefix) or opts.usePrefix)
        state = _(state).mapKeys (value, key) => "#{@prefix}_#{key}"
          .extend(@alienState).value()
      state

    ###*
     * Sets current state.
     * @param {Object} state - Queryparams for the new state
    ###
    setState: (state={}) ->
      @state = @stripEmptyOrDefault @unprefixKeys state
      @trigger 'stateChange', this, @state
      @fetch(reset: true)?.fail => @reset()

    ###*
     * Strips the state from all undefined or default values
    ###
    stripEmptyOrDefault: (state, opts={}) ->
      return state = _.omit state, (value, key) =>
        value is undefined or
          (_.isEqual(@DEFAULTS[key], value) and !opts.inclDefaults)

    ###*
     * Saves all alien values (without prefixes) into a separete hash
     * (to return on getState()). Renames prefixed keys into normal form.
     * @return {Object}
    ###
    unprefixKeys: (state) ->
      return state unless @prefix
      @alienState = {}
      return state = _(state).omit (value, key) =>
        if alien = key.indexOf(@prefix) < 0
          @alienState[key] = value
        return alien
      .mapKeys (value, key) => key.replace "#{@prefix}_", ''
      .value()

    ###*
     * Incorporate the collection state.
     * @param   {String} urlRoot optional urlRoot to calculate url, if it's
     *                           not set this.urlRoot will be used.
     * @returns {String}
    ###
    url: (urlRoot=@urlRoot, state) ->
      throw new Error 'Please define a urlRoot
        when implementing a collection' unless urlRoot
      state = @getState {}, inclDefaults: yes, usePrefix: no unless state
      # convert from local state keys to server state keys
      state = _.mapKeys state, (value, key) =>
        _.invert(@DEFAULTS_SERVER_MAP)[key] or key
      # format the url for the ajax call
      base = if _.isFunction(urlRoot) then urlRoot.apply(this) else urlRoot
      query = utils.querystring.stringify state
      @urlWithQuery base, query

    ###*
     * Combines URL base with query params.
     * @param  {String|Array|Object} base Base part of the URL, it supported
     *                                    in form of Array (of URLs), Object
     *                                    (Hash of URLs) or String (just URL).
     * @param  {String} query             Query params string
     * @return {String|Array|Object}      A new instance of amended base.
    ###
    urlWithQuery: (base, query) ->
      url = base
      if query
        if _.isString base
          url = "#{base}?#{query}"
        else if _.isArray(base) and base.length > 0
          bases = _.clone base
          bases[0] = "#{_.first(bases)}?#{query}"
          url = bases
        else if _.isObject(base) and keys = _.keys base
          bases = _.clone base
          firstKey = _.first keys
          bases[firstKey] = "#{bases[firstKey]}?#{query}"
          url = bases
      url

    parse: (resp) ->
      if @syncKey
        @count = parseInt resp.count
        resp[@syncKey]
      else resp

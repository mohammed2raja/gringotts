define (require) ->
  utils = require 'lib/utils'
  helper = require '../helper'

  ###*
   * Adds a capability of scoping a Collection or Model url with custom query
   * params for every sync request.
   * Adds a persistent state storage to keep track of all parameters that
   * has to be added to the url.
   * Adds support of default state parameter values and translation of client
   * param keys to server onces. Also with ability to ignore some of the
   * keys.
   * If there are multiple instances of a Collection or a Model assined to
   * views on the same screen, please use prefix property to distringuish
   * state params before passing it to Chaplin routing system.
   * @param  {Model|Collection} superclass
  ###
  (superclass) -> class StatefulUrlParams extends superclass
    ###*
     * Default query params hash for this collection.
     * Override when necessary.
    ###
    DEFAULTS: {}

    ###*
     * Used to map local param names to queryparam server attrs
     * Override when necessary.
    ###
    DEFAULTS_SERVER_MAP: {}

    ###*
     * State storage for the params.
     * @type {Object}
    ###
    state: null

    ###*
     * Custom string keyword to scope input state keys. Useful if there is
     * a case of using two or more instances of a Model assigned to views
     * on the browser page.
     * @type {String}
    ###
    prefix: null

    ###*
     * List of state keys to ignore while building url for fetching items.
     * @type {Array}
    ###
    ignoreKeys: null

    initialize: ->
      helper.assertModelOrCollection this
      unless typeof @url is 'function'
        throw new Error 'Please use urlRoot instead
          of url as a URL property for syncing.'
      super
      @state = {}

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
      state = _.omit state, (value, key) =>
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
      state = _(state).omit (value, key) =>
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
      state = _.mapKeys _.omit(state, @ignoreKeys), (value, key) =>
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

    ###*
     * A simple proxy object with only getState method to pass around.
     * @return {Object}
    ###
    proxyState: ->
      getState: _.bind @getState, this

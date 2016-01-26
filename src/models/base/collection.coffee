define (require) ->
  Chaplin = require 'chaplin'
  advice = require '../../mixins/advice'
  Model = require './model'
  safeAjaxCallback = require '../../mixins/safe-ajax-callback'
  serviceUnavailable = require '../../mixins/service-unavailable'
  utils = require '../../lib/utils'

  ###*
   * @prop {string} [comparator] - Effective switch to local sorting.
  ###
  class Collection extends Chaplin.Collection
    _.extend @prototype, Chaplin.SyncMachine

    _.each [
      advice # needs to come first
      safeAjaxCallback
      serviceUnavailable
    ], (mixin) ->
      mixin.call @prototype
    , this

    model: Model

    initialize: ->
      super
      @state = {}

      throw new Error(
        'Please use urlRoot instead of url as a collection property'
      ) unless typeof @url is 'function'

      # apply the sync machine
      utils.initSyncMachine this

      # Without this collections keep growing and it causes problems with new
      # notifications being inserted after old ones are disposed.
      @on 'dispose', (model) ->
        @remove model if model instanceof Chaplin.Model and !@disposed

      @on 'remove', -> @count = Math.max 0, (@count or 1) - 1

    ###*
     * State of the data with relation to the server.
     * @type {Object}
    ###
    state: null

    ###*
     # Default queryparam object for this collection.
     # Must contain all possible querynewState.
     # Override when necessary.
    ###
    DEFAULTS:
      order: 'desc'
      q: undefined
      sort_by: undefined
      page: 1

    ###*
     # Used to map local property names to queryparam server attrs
     # Override when necessary.
    ###
    DEFAULTS_SERVER_MAP: {}

    ###*
     * Return whether or not the prop/val is a default one.
     * @param  {string}  prop - local formatted prop name
     * @param  val  - Value of the property
     * @return {Boolean}
    ###
    _isDefault: (key, val) ->
      serverKey = _.invert(@DEFAULTS_SERVER_MAP)[key] or key
      _.isEqual @DEFAULTS[serverKey], val

    _stripState: (state, withDefaults=false) ->
      _.omit state, (v, k) ->
        v is undefined or (@_isDefault(k, v) and !withDefaults)
      , this

    ###*
     # Generate a state from the given and current states.
     # Whenever we getState we need to pass in all non-default
     # prop/values that we want.
     # @prop {object} overrides - Optional local-formatted state to include or
     #                            override.
     # @prop {boolean} withDefaults
     # @returns {object} state
    ###
    getState: (overrides={}, withDefaults=false) ->
      defaults = _.mapKeys @DEFAULTS, (value, key) ->
        @DEFAULTS_SERVER_MAP[key] or key
      , this

      state = _.extend {}, defaults, @state, overrides

      # make sure only local properties are being passed in
      unless _.isEmpty _.intersection(
        _.keys(state), _.keys(@DEFAULTS_SERVER_MAP)
      ) then throw new Error 'Pass in only local state properties.'

      # omit undefined values & defaults unless we need them
      @_stripState(state, withDefaults)

    ###*
     # @param {object} state - Queryparams for the new state
    ###
    setState: (state={}) ->
      @state = @_stripState state

      # if it's a remote sort, always fetch
      @fetch {reset: true}

    ###*
     * Abort the fetch request if one is already being made.
    ###
    fetch: ->
      @currentXHR.abort() if @currentXHR and @isSyncing()
      @currentXHR = super

    ###*
     * Incorporate the collection state.
     * @param   {string} urlRoot optional urlRoot to calculate url, if it's
     *                           not set this.urlRoot will be used.
     * @returns {string}
    ###
    url: (urlRoot=@urlRoot, state=@getState({}, true)) ->
      throw new Error(
        'Please define a urlRoot when implementing a collection'
      ) unless urlRoot

      # convert from local state keys to server state keys
      queryState = _.mapKeys state, (value, key) ->
        _.invert(@DEFAULTS_SERVER_MAP)[key] or key
      , this

      # format the url for the ajax call
      query = utils.querystring.stringify queryState
      base = if _.isFunction(urlRoot) then urlRoot.apply this else urlRoot
      if query then "#{base}?#{query}" else "#{base}"

    parse: (resp) ->
      if @syncKey
        @count = parseInt resp.count
        resp[@syncKey]
      else resp

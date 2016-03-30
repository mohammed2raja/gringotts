define (require) ->
  Chaplin = require 'chaplin'
  utils = require '../../lib/utils'
  advice = require '../../mixins/advice'
  activeSyncMachine = require '../../mixins/active-sync-machine'
  overrideXHR = require '../../mixins/override-xhr'
  safeSyncCallback = require '../../mixins/safe-sync-callback'
  serviceErrorCallback = require '../../mixins/service-error-callback'
  Model = require './model'

  # Generic base class for collections. Includes useful mixins by default.
  class Collection extends Chaplin.Collection
    _.extend @prototype, activeSyncMachine, safeSyncCallback,
      serviceErrorCallback, overrideXHR
    advice.call @prototype

    model: Model

    initialize: ->
      super
      @state = {}

      throw new Error(
        'Please use urlRoot instead of url as a collection property'
      ) unless typeof @url is 'function'

      @activateSyncMachine()

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
     * Default queryparam object for this collection.
     * Must contain all possible querynewState.
     * Override when necessary.
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
     * Strips the state from all undefined or default values
     * @param  {Object} state
     * @param  {Boolean} withDefaults=false whether defaults should be removed
    ###
    _stripState: (state, withDefaults=false) ->
      _.omit state, (value, key) =>
        value is undefined or
          _.isEqual(@DEFAULTS[key], value) and !withDefaults

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
      state = _.extend {}, @DEFAULTS, @state, overrides

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
      @trigger 'stateChange', this, @state
      @fetch reset: true
      .fail => @reset()

    sync: ->
      @serviceErrorCallback.apply this, arguments
      @safeSyncCallback.apply this, arguments # should be after service-error
      @safeDeferred super

    fetch: ->
      @overrideXHR super

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
      queryState = _.mapKeys state, (value, key) =>
        _.invert(@DEFAULTS_SERVER_MAP)[key] or key

      # format the url for the ajax call
      query = utils.querystring.stringify queryState
      base = if _.isFunction(urlRoot) then urlRoot.apply this else urlRoot
      if query then "#{base}?#{query}" else "#{base}"

    parse: (resp) ->
      if @syncKey
        @count = parseInt resp.count
        resp[@syncKey]
      else resp

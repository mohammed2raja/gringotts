define (require) ->
  Chaplin = require 'chaplin'
  advice = require '../../mixins/advice'
  activeSyncMachine = require '../../mixins/active-sync-machine'
  overrideXHR = require '../../mixins/override-xhr'
  safeSyncCallback = require '../../mixins/safe-sync-callback'

  # Generic base class for models. Includes useful mixins by default.
  class Model extends Chaplin.Model
    _.extend @prototype, activeSyncMachine, safeSyncCallback, overrideXHR
    advice.call @prototype

    initialize: ->
      super
      @activateSyncMachine()

    save: (key, val, options) ->
      super or $.Deferred() # handling validation false result
        .reject error: @validationError
        .always =>
          return unless @validationError
          @publishEvent 'notify',
            @validationError[key] or
              if _.isObject @validationError
              then _.first _.values @validationError
              else @validationError,
            classes: 'alert-danger'
        .promise()

    sync: ->
      @safeSyncCallback.apply this, arguments
      @safeDeferred super

    fetch: ->
      @overrideXHR super

define (require) ->
  Chaplin = require 'chaplin'
  utils = require '../../lib/utils'
  ActiveSyncMachine = require '../../mixins/active-sync-machine'
  OverrideXHR = require '../../mixins/override-xhr'
  SafeSyncCallback = require '../../mixins/safe-sync-callback'

  # Abstract class for models. Includes useful mixins by default.
  class Model extends utils.mix Chaplin.Model
      .with ActiveSyncMachine, OverrideXHR, SafeSyncCallback

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

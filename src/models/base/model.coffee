define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  ActiveSyncMachine = require '../../mixins/models/active-sync-machine'
  Abortable = require '../../mixins/models/abortable'
  SafeSyncCallback = require '../../mixins/models/safe-sync-callback'
  ErrorHandled = require '../../mixins/models/error-handled'
  WithHeaders = require '../../mixins/models/with-headers'

  ###*
   *  Abstract class for models. Includes useful mixins by default.
  ###
  class Model extends utils.mix Chaplin.Model
      .with WithHeaders, ActiveSyncMachine, Abortable
        , SafeSyncCallback, ErrorHandled

    save: (key, val, options) ->
      promise = super or $.Deferred() # handling validation false result
      if @validationError
        message = @validationError[key] or
          if _.isObject @validationError
          then _.first _.values @validationError
          else @validationError
        promise.reject new Error message
      else
        promise

Chaplin = require 'chaplin'
ActiveSyncMachine = require '../../mixins/models/active-sync-machine'
Abortable = require '../../mixins/models/abortable'
SafeSyncCallback = require '../../mixins/models/safe-sync-callback'
ErrorHandled = require '../../mixins/models/error-handled'
WithHeaders = require '../../mixins/models/with-headers'

###*
  *  Abstract class for models. Includes useful mixins by default.
###
module.exports = class Model extends ActiveSyncMachine ErrorHandled \
    WithHeaders Abortable SafeSyncCallback Chaplin.Model

  save: (key, val, options) ->
    # handling validation false result
    promise = super(arguments...) or $.Deferred()
    if @validationError
      message = @validationError[key] or
        if _.isObject @validationError
        then _.head _.values @validationError
        else @validationError
      promise.reject new Error message
    else
      promise

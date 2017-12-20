import Chaplin from 'chaplin'
import ActiveSyncMachine from '../../mixins/models/active-sync-machine'
import Abortable from '../../mixins/models/abortable'
import SafeSyncCallback from '../../mixins/models/safe-sync-callback'
import ErrorHandled from '../../mixins/models/error-handled'
import WithHeaders from '../../mixins/models/with-headers'

###*
  *  Abstract class for models. Includes useful mixins by default.
###
export default class Model extends ActiveSyncMachine ErrorHandled \
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

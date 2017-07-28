Chaplin = require 'chaplin'
ActiveSyncMachine = require '../../mixins/models/active-sync-machine'
Abortable = require '../../mixins/models/abortable'
SafeSyncCallback = require '../../mixins/models/safe-sync-callback'
ErrorHandled = require '../../mixins/models/error-handled'
ServiceErrorHandled = require '../../mixins/models/service-error-handled'
WithHeaders = require '../../mixins/models/with-headers'
Model = require './model'

###*
  *  Abstract class for collections. Includes useful mixins by default.
###
module.exports = class Collection extends ActiveSyncMachine \
    ServiceErrorHandled ErrorHandled WithHeaders Abortable  \
    SafeSyncCallback Chaplin.Collection

  model: Model

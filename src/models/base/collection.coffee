define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  ActiveSyncMachine = require '../../mixins/models/active-sync-machine'
  Abortable = require '../../mixins/models/abortable'
  SafeSyncCallback = require '../../mixins/models/safe-sync-callback'
  ServiceErrorCallback = require '../../mixins/models/service-error-callback'
  WithHeaders = require '../../mixins/models/with-headers'
  Model = require './model'

  ###*
   *  Abstract class for collections. Includes useful mixins by default.
  ###
  class Collection extends utils.mix Chaplin.Collection
      .with WithHeaders, ActiveSyncMachine, Abortable
        , SafeSyncCallback, ServiceErrorCallback

    model: Model

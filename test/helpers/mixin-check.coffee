define (require) ->
  ActiveSyncMachine = require 'mixins/active-sync-machine'
  Abortable = require 'mixins/abortable'
  SafeSyncCallback = require 'mixins/safe-sync-callback'
  ServiceErrorCallback = require 'mixins/service-error-callback'
  WithHeaders = require 'mixins/with-headers'

  class CheckActiveSyncMachine extends ActiveSyncMachine Object
  class CheckAbortable extends Abortable Object
  class CheckSafeSyncCallback extends SafeSyncCallback Object
  class CheckServiceErrorCallback extends ServiceErrorCallback Object
  class CheckWithHeaders extends WithHeaders Object

  'ActiveSyncMachine': CheckActiveSyncMachine
  'Abortable': CheckAbortable
  'SafeSyncCallback': CheckSafeSyncCallback
  'ServiceErrorCallback': CheckServiceErrorCallback
  'WithHeaders': CheckWithHeaders

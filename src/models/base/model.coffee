define (require) ->
  Chaplin = require 'chaplin'
  advice = require '../../mixins/advice'
  safeAjaxCallback = require '../../mixins/safe-ajax-callback'
  serviceUnavailable = require '../../mixins/service-unavailable'
  syncFetch = require '../../mixins/sync-fetch'

  # Generic base class for models. Includes useful mixins by default.
  class Model extends Chaplin.Model
    _.extend @prototype, Chaplin.SyncMachine
    _.each [
        advice
        safeAjaxCallback
        serviceUnavailable
        syncFetch
    ], (mixin) ->
      mixin.call @prototype
    , this

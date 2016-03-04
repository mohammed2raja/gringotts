define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  advice = require '../../mixins/advice'
  safeSyncCallback = require '../../mixins/safe-sync-callback'

  # Generic base class for models. Includes useful mixins by default.
  class Model extends Chaplin.Model
    _.extend @prototype, Chaplin.SyncMachine
    _.extend @prototype, safeSyncCallback
    advice.call @prototype

    initialize: ->
      super
      utils.initSyncMachine this

    sync: ->
      @safeSyncCallback.apply this, arguments
      super

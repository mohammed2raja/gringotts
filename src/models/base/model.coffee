define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  advice = require '../../mixins/advice'
  overrideXHR = require '../../mixins/override-xhr'
  safeSyncCallback = require '../../mixins/safe-sync-callback'

  # Generic base class for models. Includes useful mixins by default.
  class Model extends Chaplin.Model
    _.extend @prototype, Chaplin.SyncMachine
    _.extend @prototype, safeSyncCallback
    _.extend @prototype, overrideXHR

    advice.call @prototype # needs to come first

    initialize: ->
      super
      utils.initSyncMachine this

    sync: ->
      @safeSyncCallback.apply this, arguments
      super

    fetch: ->
      @overrideXHR super

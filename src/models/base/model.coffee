define (require) ->
  Chaplin = require 'chaplin'
  advice = require '../../mixins/advice'
  safeAjaxCallback = require '../../mixins/safe-ajax-callback'
  utils = require 'lib/utils'

  # Generic base class for models. Includes useful mixins by default.
  class Model extends Chaplin.Model
    _.extend @prototype, Chaplin.SyncMachine

    _.each [
      advice
      safeAjaxCallback
    ], (mixin) ->
      mixin.call @prototype
    , this

    initialize: ->
      super
      utils.initSyncMachine this

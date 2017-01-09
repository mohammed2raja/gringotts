define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  SafeSyncCallback = require '../../mixins/models/safe-sync-callback'

  ###*
   * Aborts the existing fetch request if a new one is being requested.
  ###
  (base) -> class Abortable extends utils.mix(base).with SafeSyncCallback
    helper.setTypeName @prototype, 'Abortable'

    initialize: ->
      helper.assertModelOrCollection this
      super

    fetch: ->
      @currentXHR.abort() if @currentXHR
      @currentXHR = utils.abortable super,
        then: (r, s, $xhr) =>
          delete @currentXHR
          $xhr

    sync: (method, model, options={}) ->
      error = options.error
      options.error = ($xhr) ->
        # cancel default error handler for abort errors
        unless $xhr.statusText is 'abort'
          error?.apply this, arguments
      super

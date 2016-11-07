define (require) ->
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  ActiveSyncMachine = require './active-sync-machine'

  ###*
   * Aborts the existing fetch request if a new one is being requested.
  ###
  (base) -> class Abortable extends utils.mix(base).with ActiveSyncMachine
    helper.setTypeName @prototype, 'Abortable'

    initialize: ->
      helper.assertModelOrCollection this
      super

    fetch: ->
      $xhr = super
      if @currentXHR and _.isFunction(@currentXHR.abort) and @isSyncing()
        @currentXHR
          # muting the ajax error raised during abort
          .fail ($xhr) -> $xhr.errorHandled = true if $xhr.status is 0
          .abort()
      @currentXHR = if $xhr then $xhr.always => delete @currentXHR

    sync: (method, model, options={}) ->
      error = options.error
      options.error = ($xhr) ->
        # cancel default error handler for abort errors
        if $xhr.statusText is 'abort'
          $xhr.errorHandled = true
        else
          error?.apply this, arguments
      super

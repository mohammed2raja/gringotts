define (require) ->
  Chaplin = require 'chaplin'
  Model = require './model'
  advice = require '../../mixins/advice'
  paginationStats = require '../../mixins/pagination-stats'
  parseResponse = require '../../mixins/parse-response'
  safeAjaxCallback = require '../../mixins/safe-ajax-callback'
  serviceUnavailable = require '../../mixins/service-unavailable'
  scopeable = require '../../mixins/scopeable'
  syncFetch = require '../../mixins/sync-fetch'

  # Generic base class for collections. Includes useful mixins by default.
  class Collection extends Chaplin.Collection
    _.extend @prototype, Chaplin.SyncMachine
    # Additonal logic in `sync` and `fetch` should be done with AOP.
    _.each [
      advice # Advice needs to come first.
      paginationStats
      parseResponse
      safeAjaxCallback
      serviceUnavailable
      scopeable
      syncFetch
    ], (mixin) ->
      mixin.call @prototype
    , this

    DEFAULTS:
      page: 1
      per_page: 30
      order: 'asc'

    model: Model

    @::before 'initialize', ->
      # Without this collections keep growing and it causes problems with new
      # notifications being inserted after old ones are disposed.
      @on 'dispose', (model) -> @remove model

    pageString: (stats) ->
      I18n?.t 'items.total', stats

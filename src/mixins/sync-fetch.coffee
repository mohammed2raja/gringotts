# This mixin triggers the start and end sync state for objects
# that have mixed in `SyncMachine`.
#
# It uses `flight/advice` for AOP to start the machine
# before `fetch()`.
define (require, exports) ->
  advice = require 'flight/advice'

  syncFetch = ->
    if @beginSync
      # Kick off SyncMachine before fetch.
      @beginSync()
      @on 'sync', @finishSync, this

  exports = ->
    @before 'fetch', syncFetch
    this

# This mixin alerts the user when APIs are down via a `notify` event through
# `publishEvent`. A `service-unavailable` event is triggered on
# the model/collection as well.
define (require) ->
  _ = require 'underscore'
  utils = require 'lib/utils'

  serviceErrorCallback = (method, collection, opts = {}) ->
    callback = opts.error
    opts.error = ($xhr) =>
      {status} = $xhr
      # Don't trigger for canceled requests.
      if status isnt 0
        callback?.apply (opts.context or opts), arguments
        # Removes loading indicators present.
        @abortSync?()
        # `trigger` is a safe operation even if disposed.
        @trigger 'service-unavailable'

  ->
    @before 'sync', serviceErrorCallback

    this

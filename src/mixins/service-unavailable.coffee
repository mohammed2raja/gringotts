# This mixin alerts the user when APIs are down via a `notify` event through
# `publishEvent`. A more specific message is shown for errors with a `418`
# status code. A `service-unavailable` event is triggered on the model/collection
# as well.
#
# The `I18n` library is invoked if it exists, otherwise it uses a default.
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
        # the notification for 418 is handled in the serviceUnavailableCallback
        if status isnt 418
          error = I18n?.t('error.notification') or
            "There was a problem communicating with the server."
          @publishEvent 'notify', error,
            classes: 'alert-danger'

  # `418` is specific to external services being down.
  serviceUnavailableCallback = (method, collection, opts = {}) ->
    callback = opts.statusCode?['418']
    opts.statusCode ||= {}
    # Make sure we don't override existing `statusCode` callbacks.
    _.extend opts.statusCode,
      # JSON response uses the `message` property when provided.
      418: ($xhr) =>
        # Invoke existing `418` callback if present.
        callback?.apply (opts.context or opts), arguments
        errorState = utils.parseJSON $xhr.responseText
        message = errorState.message or I18n?.t('error.service') or
          "There was an error communicating with the server."
        @publishEvent 'notify', message,
          classes: 'alert-danger'
          reqTimeout: 10000

  ->
    @before 'sync', serviceErrorCallback
    @before 'sync', serviceUnavailableCallback

    this

# This mixin prevent errors when sync/fetch callback executes after
# route change. It should be called in sync method.
#
# It mainly piggies back off the AJAX option hash which the Backbone
# server methods (such as `fetch` and `save`) use. This makes it
# incompatible with the related promise callbacks (`done`, `fail`, `always`).
define (require) ->
  safeSyncCallback:  (method, model, options) ->
    return unless options
    _.each ['success', 'error', 'complete'], (cb) ->
      callback = options[cb]
      if callback
        ctx = options.context or this
        options[cb] = =>
          # Check disposal at time of use.
          callback.apply ctx, arguments unless @disposed
    , this

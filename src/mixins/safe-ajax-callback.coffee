# This mixin prevent errors when sync/fetch callback executes after
# route change.
#
# It mainly piggies back off the AJAX option hash which the Backbone
# server methods (such as `fetch` and `save`) use. This makes it
# incompatible with the related promise callbacks (`done`, `fail`, `always`)
# which don't provide as nice of a hook with AOP.
define (require) ->
  _ = require 'underscore'
  advice = require 'flight/advice'

  safeAjaxCallback = (method, collection, opts = {}) ->
    _.each ['success', 'error', 'complete'], (val) ->
      callback = opts[val]
      if callback
        ctx = opts.context or this
        opts[val] = =>
          # Check disposal at time of use.
          callback.apply ctx, arguments unless @disposed
    , this

  ->
    @before 'sync', safeAjaxCallback
    this

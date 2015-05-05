# Allow a model to specify the function name to use for validation.
# The function will be invoked on the instance or default to a provided
# blank method if it does not exist.
#
# The specified function should return a truthy value only
# if there is a problem (per Backbone conventions).
define (require, exports) ->
  _ = require 'underscore'

  # Default validation criterion
  blank = (text) ->
    text.length is 0

  exports = (opts) ->
    # Map of attributes to validation method.
    {methods} = opts
    # Inlined to bind methods to the host object.
    @validate = (attrs, options) ->
      foundError = no
      errors = _.reduce methods, (memo, name, attr) ->
        method = @[name] or blank
        # Only validate attributes passed in (including ones with falsy values)
        modelErr = method.call(this, attrs[attr]) if attrs.hasOwnProperty attr
        if modelErr
          foundError = yes
          memo[attr] = modelErr
        memo
      , {}, this
      # Return falsy value if there are no errors.
      errors if foundError

    this

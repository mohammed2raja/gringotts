# This mixin handles retrieving parameters for storage on the collection
# and cleaning up the URL as needed. The parameters will be stored
# as `params` on the collection and the URL will use the `syncKey`
# property on the collection as it's base.
#
# A `DEFAULTS` object is required on the collection in addition to a
# `syncKey` string to specify the name of the URL base.
#
# In order for views to take full advantage of this, all calls to `fetch`
# should pass a `query` key into it's options in order for associated
# parameters (such as sorts, filters, etc.) are preserved between requests.
#
# Private methods need to use `call` so that the instance is used over the
# constructor or global object.
#coffeelint: disable=cyclomatic_complexity
define (require) ->
#coffeelint: enable=cyclomatic_complexity
  _ = require 'underscore'
  advice = require 'flight/advice'
  utils = require '../lib/utils'

  # Extract params and fill in falsy values with defaults for server request.
  _collectParams = (query) ->
    params = utils.queryParams.parse query
    # Can't iterate over params since it might be missing keys.
    _.reduce @DEFAULTS, (memo, value, key) ->
      value = params[key] or value
      # Convert string numbers to numbers.
      value = +value if (+value).toString() is value
      memo[key] = value
      memo
    , params

  # This will remove default parameters to make the URL "pretty".
  _removeDefaults = (params) ->
    _.reduce params, (memo, value, key) ->
      defaultVal = @DEFAULTS[key]
      comparison =
        if _.isArray value
          _.uniq(value.concat defaultVal)
        else
          defaultVal
      # Use `isEqual` in case the values are arrays
      unless _.isEqual comparison, value
        memo[key] = value
      memo
    , {}, this

  # Use to construct the URL to route to.
  scopedUrl = (scope) ->
    # All non-default params passed in will be sent to the server.
    params = _.extend {}, @params, scope
    # Handle sort with standard `asc` and `desc` order.
    if scope.sort_by
      params.order = 'asc'
      if @params.sort_by is params.sort_by and @params.order is 'asc'
        params.order = 'desc'

    params = _removeDefaults.call this, params
    # The collection can provide a `getPageURL` method to be used to generate
    # the href for page links.
    if @getPageURL
      @getPageURL params
    else
      utils.reverse @syncKey, null, params

  ->
    @before 'sync', (method, collection, opts) ->
      if method is 'read'
        # Add `params` to the collection.
        @params = _collectParams.call this, opts.query
        cleanParams = _removeDefaults.call this, @params
        # Only show `params` that aren't defaults in URL.
        opts.data =
          if opts.data
            _.extend opts.data, cleanParams
          else
            cleanParams

    @scopedUrl = scopedUrl

    this

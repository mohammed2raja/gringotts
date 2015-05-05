# This mixin allows a collection to parse out it's nested API response
# with the presence of `syncKey` on the collection.
#
# The collection will pull and store `count` from the response onto
# the collection. It will return the models namespaced under
# the collection's `syncKey` property.
define (require, exports) ->
  # Handle API that returns payload in nested array with count.
  # **e.g.** `{"#{COUNT_PROP}": 1, "#{ROUTE_PROP}": [{...}]}`
  parse = (resp) ->
    # Need instance property for sub-collection to use.
    if @syncKey
      @count = resp.count
      resp[@syncKey]
    else
      resp

  exports = (opts={}) ->
    @parse = parse
    this

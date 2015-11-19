define (require) ->
  # For use on paginated collection views so we don't
  # have to recreate a new view for each page.
  # You can specify an optional `viewName` on the collection
  # so sub-collections can use.
  reuseView = (params={}, models, View) ->
    query = params.query
    collection = @reuse params.path, models
    name = @viewName or "#{@title}-view"
    # Reset to trigger loading indicator.
    collection.reset()
    collection.fetch {query}
    opts = params.opts or {}
    opts.collection = collection
    @reuse name, View, opts

  ->
    @reuseView = reuseView
    this

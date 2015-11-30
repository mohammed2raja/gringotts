# This mixin provides logic to drive a pagination view.
# Paging is updated on sync states and item removal.
#
# It requires the view collection to have `paginationStats`
# mixed in.
define (require) ->
  getTemplateData = ->
    @stats.num_items = @collection.pageString @stats
    @stats

  ->
    @tagName = 'span'
    @className = "collection-pagination #{@className or ''}"

    # 'Extend' the `listen` hash, even if it's not present, without
    # having this handler overridden if the hash is declared later.
    @before 'delegateListeners', ->
      @delegateListener 'syncStateChange', 'collection', ->
        @stats = @collection.paginationStats()
        @render()
      @delegateListener 'remove', 'collection', ->
        # Use instance copies to preserve page parameters.
        @stats.end = Math.max 0, @stats.end - 1
        @stats.total = @collection.count
        @render()

    @before 'initialize', ->
      @stats = @collection.paginationStats()

    @getTemplateData = getTemplateData
    this

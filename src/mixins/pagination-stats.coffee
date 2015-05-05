define (require, exports) ->
  advice = require 'flight/advice'

  # This method returns an object with properties about the page and
  # item counts for the given state of the `collection`.
  #
  # The `collection` should have `scopeable` mixed in or an equivalent
  # [`scopedUrl`](https://github.com/pages/lookout/gringotts/src/mixins/scopeable.html)
  # method with associated properties `params` and `count`.
  paginationStats = ->
    # Pull `page` and `per_page` directly off `params` on the `collection`.
    page = @params.page
    perPage = @params.per_page
    total = @count or 0
    # Previous page end plus one.
    start = (page - 1) * perPage + 1
    end = Math.min page * perPage, total

    if total
      maxPage = Math.ceil total / perPage
      if page > maxPage
        # Direct out of bound pages to last page.
        prevPage = @scopedUrl page: maxPage
      else if page isnt 1
        prevPage = @scopedUrl page: page - 1

      if page < maxPage
        nextPage = @scopedUrl page: page + 1

    # Flag that can be used to hide pagination if there are no items
    # or items all fit on one page.
    showPagination = prevPage or nextPage
    {
      # URL w/ query params.
      nextPage
      prevPage
      # Boolean
      showPagination
      # Numbers
      start
      end
      total
    }

  pageString = (stats) ->
    "#{stats.start}-#{stats.end} of #{stats.total}"

  exports = ->
    @before 'initialize', ->
      @on 'remove', ->
        # Keep pagination views in sync on archive/delete.
        @count = Math.max 0, @count - 1

    @paginationStats = paginationStats
    @pageString = pageString
    this

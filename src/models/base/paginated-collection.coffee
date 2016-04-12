define (require) ->
  Collection = require './collection'

  ###*
  # The Collection from which to extend for pagination needs.
  ###
  class PaginatedCollection extends Collection
    DEFAULTS: _.extend {}, @::DEFAULTS,
      page: 1
      per_page: 30

    ###*
     * Sets the pagination mode for collection.
     * @type {Boolean} True if infitine, false otherwise
    ###
    infinite: false

    parse: (resp) ->
      @nextPageId = resp.next_page_id if @infinite
      super

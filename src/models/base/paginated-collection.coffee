define (require) ->
  Collection = require './collection'

  ###*
  # The Collection from which to extend for pagination needs.
  ###
  class PaginatedCollection extends Collection
    DEFAULTS: _.extend {}, @::DEFAULTS,
      page: 1
      per_page: 30

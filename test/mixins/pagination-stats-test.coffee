define (require) ->
  utils = require 'lib/utils'
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  paginationStats = require 'mixins/pagination-stats'
  scopeable = require 'mixins/scopeable'

  class TestCollection extends Chaplin.Collection
    _.each [advice, paginationStats, scopeable], (mixin) ->
      mixin.call @prototype
    , this
    DEFAULTS: {page: 1, per_page: 30}

  describe 'Pagination stats mixin', ->
    # Return an array with {{num}} empty objects.
    createItems = (num) ->
      # http://ariya.ofilabs.com/2013/07/sequences-using-javascript-array.html
      Array.apply(0, Array num).map -> {}

    beforeEach ->
      sinon.stub utils, 'reverse', (name, params, query) ->
        "/ent/#{name}?#{utils.queryParams.stringify query}"
      @items = createItems 60
      @collection = new TestCollection @items
      @collection.count = @items.length
      @collection.params = _.clone @collection.DEFAULTS
      @results = @collection.paginationStats()

    afterEach ->
      utils.reverse.restore()
      @collection.dispose()

    describe 'with 60 items', ->
      afterEach ->
        expect(@results.total).to.equal 60

      it 'should render properly for defaults', ->
        expect(@results.start).to.equal 1
        expect(@results.end).to.equal 30
        expect(@results.nextPage).to.contain 'page=2'

      it 'renders correct page', ->
        @collection.params.page = 2
        @results = @collection.paginationStats()
        expect(@results.start).to.equal 31
        expect(@results.end).to.equal 60

      it 'acknowledges per page param', ->
        @collection.params.per_page = 10
        @results = @collection.paginationStats()
        expect(@results.start).to.equal 1
        expect(@results.end).to.equal 10

      it 'works with both params', ->
        @collection.params.page = 3
        @collection.params.per_page = 15
        @results = @collection.paginationStats()
        expect(@results.start).to.equal 31
        expect(@results.end).to.equal 45
        expect(@results.prevPage).to.contain 'page=2&per_page=15'
        expect(@results.nextPage).to.contain 'page=4&per_page=15'

    it 'shows the total for end index with uneven counts', ->
      @collection.count = 100
      @collection.params.page = 4
      @results = @collection.paginationStats()
      expect(@results.start).to.equal 91
      expect(@results.end).to.equal 100
      expect(@results.total).to.equal 100

    it 'allows user to get to the last page from an invalid page', ->
      @collection.params.page = 10
      @results = @collection.paginationStats()
      expect(@results.prevPage).to.contain 'page=2'

    it 'allows user to get to the last page from an invalid per page', ->
      @collection.params.page = 2
      @collection.params.per_page = 99
      @results = @collection.paginationStats()
      expect(@results.prevPage).to.contain 'per_page=99'
      expect(@results.prevPage).not.to.contain 'page=1'

    describe 'pageString', ->
      it 'returns the correct string', ->
        stats = start: 1, end: 30, total: 60
        expect(@collection.pageString stats).to.equal '1-30 of 60'

    describe 'when removing an item', ->
      beforeEach ->
        @collection.remove @collection.first()

      it 'updates the count', ->
        expect(@collection.count).to.equal 59

    describe 'hides the arrows', ->
      afterEach ->
        results = @collection.paginationStats()
        expect(results.showPagination).to.be.undefined

      it 'when collection fits on the first page', ->
        @collection.params.per_page = 60

      it 'when the count is zero', ->
        @collection.count = 0

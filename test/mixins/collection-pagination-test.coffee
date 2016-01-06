define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  advice = require 'mixins/advice'
  scopeable = require 'mixins/scopeable'
  paginationStats = require 'mixins/pagination-stats'
  collectionPagination = require 'mixins/collection-pagination'

  class CollectionPaginationView extends Chaplin.View
    advice.call @prototype
    collectionPagination.call @prototype
    autoRender: yes
    getTemplateFunction: ->
      -> 'foo'

  class FakeCollection extends Chaplin.Collection
    _.extend @prototype, Chaplin.SyncMachine
    _.each [advice, paginationStats, scopeable], (mixin) ->
      mixin.call @prototype
    , this
    DEFAULTS:
      page: 1
      per_page: 30

  describe 'CollectionPaginationView', ->
    # Return an array with {{num}} empty objects.
    createItems = (num) ->
      # http://ariya.ofilabs.com/2013/07/sequences-using-javascript-array.html
      Array.apply(0, Array num).map -> {}

    beforeEach ->
      sinon.stub utils, 'reverse', (name, params, query) ->
        "/ent/#{name}?#{utils.queryParams.stringify query}"
      @items = createItems 60
      @collection = new FakeCollection @items
      @collection.beginSync()
      @collection.count = @items.length
      @collection.params = _.extend {}, (@params or @collection.DEFAULTS)
      sinon.spy @collection, 'paginationStats'
      @view = new CollectionPaginationView {@collection}

    afterEach ->
      utils.reverse.restore()
      @view.dispose()
      @collection.dispose()

    it 'calls pagination stats', ->
      expect(@collection.paginationStats).to.be.calledOnce

    describe 'after sync', ->
      beforeEach ->
        @collection.finishSync()

      it 'calls pagination stats again', ->
        expect(@collection.paginationStats).to.be.calledTwice

    describe 'after remove', ->
      beforeEach ->
        @collection.remove @collection.first()

      it 'decrements end', ->
        expect(@view.stats.end).to.equal 29

      it 'updates total', ->
        expect(@view.stats.total).to.equal 59

    describe 'getTemplateData', ->
      it 'sets num_items', ->
        expect(@view.getTemplateData().num_items).to.equal '1-30 of 60'

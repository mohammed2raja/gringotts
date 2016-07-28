define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  Paginated = require 'mixins/models/paginated'
  SyncKey = require 'mixins/models/sync-key'
  StatefulUrlParams = require 'mixins/models/stateful-url-params'

  class MockPaginatedCollection extends Paginated Chaplin.Collection
    syncKey: 'someItems'
    urlRoot: '/test'

  describe 'Paginated mixin', ->
    sandbox = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      collection = new MockPaginatedCollection()

    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should be instantiated', ->
      expect(collection).to.be.instanceOf MockPaginatedCollection

    it 'should have proper mixins applied', ->
      expect(utils.instanceWithMixin collection, StatefulUrlParams).to.be.true
      expect(utils.instanceWithMixin collection, SyncKey).to.be.true

    context 'fetching', ->
      infinite = false

      beforeEach ->
        collection.infinite = infinite
        collection.fetch()
        sandbox.server.respondWith [200, {}, JSON.stringify {
          count: 3
          someItems: [{}, {}, {}]
          next_page_id: 555
        }]
        sandbox.server.respond()

      it 'should query the server with the default state', ->
        request = _.last sandbox.server.requests
        _.each ['page=1', 'per_page=30'], (i) ->
          expect(request.url).to.contain i

      it 'should parse response correctly', ->
        expect(collection.count).to.equal 3
        expect(collection.length).to.equal 3
        expect(collection.nextPageId).to.be.undefined

      context 'when pagination is infinite', ->
        before ->
          infinite = true

        after ->
          infinite = false

        it 'should read next page id', ->
          expect(collection.nextPageId).to.equal 555

      context 'on remove items', ->
        beforeEach ->
          collection.remove _.first collection.models

        it 'should update count', ->
          expect(collection.count).to.equal 2

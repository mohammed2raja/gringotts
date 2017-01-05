define (require) ->
  Chaplin = require 'chaplin'
  helper = require 'lib/mixin-helper'
  Paginated = require 'mixins/models/paginated'
  SyncKey = require 'mixins/models/sync-key'
  ForcedReset = require 'mixins/models/forced-reset'
  Queryable = require 'mixins/models/queryable'

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
      expect(helper.instanceWithMixin collection, Queryable).to.be.true
      expect(helper.instanceWithMixin collection, SyncKey).to.be.true
      expect(helper.instanceWithMixin collection, ForcedReset).to.be.true

    context 'fetching', ->
      infinite = null
      $xhr = null

      beforeEach ->
        collection.count = 500
        collection.infinite = infinite
        $xhr = collection.fetch()
        return

      context 'on done', ->
        beforeEach ->
          sandbox.server.respondWith JSON.stringify
            count: 3
            someItems: [{}, {}, {}]
            next_page_id: 555
          sandbox.server.respond()

        it 'should query the server with the default query params', ->
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

      context 'on fail', ->
        beforeEach ->
          sandbox.server.respondWith [500, {}, '{}']
          sandbox.server.respond()

        it 'should reset count to 0', ->
          expect(collection.count).to.equal 0

      context 'on abort', ->
        beforeEach ->
          $xhr.abort()
          return

        it 'should not reset count', ->
          expect(collection.count).to.equal 500

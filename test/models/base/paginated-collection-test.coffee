define (require) ->
  PaginatedCollection = require 'models/base/paginated-collection'
  utils = require 'lib/utils'

  class MockPaginatedCollection extends PaginatedCollection
    syncKey: 'tests'
    urlRoot: '/test'

  describe 'Pagination Collection', ->
    collection = null
    server = null
    state = null

    beforeEach ->
      server = sinon.fakeServer.create()
      collection = new MockPaginatedCollection()
      collection.fetch()
      server.respond()

    afterEach ->
      server.restore()
      collection.dispose()

    it 'should instantiate', ->
      expect(collection).to.be.an.instanceOf MockPaginatedCollection

    it 'should query the server with the default state', ->
      url = server.requests[0].url
      _.each ['page=1', 'per_page=30', 'order=desc'], (i) ->
        expect(url).to.contain i

    it 'should start the local state with no default params', ->
      expect(collection.state).to.eql {}

    context 'collection state', ->
      beforeEach ->
        collection.setState state or {}
        server.respond()

      it 'should return an empty state when no defaults are desired', ->
        expect(collection.getState()).to.eql {}

      it 'should return the default state when desired', ->
        expect(collection.getState {}, inclDefaults: yes).to.eql {
          page: 1
          per_page: 30
          order: 'desc'
        }

      context 'with an updated state', ->
        before ->
          state =
            page: 2
            per_page: 10
            q: 'testSearch'

        after -> state = null

        it 'should query the server with the correct state', ->
          url = server.requests[1].url
          _.each [
            'page=2', 'per_page=10', 'order=desc', 'q=testSearch'
          ], (i) -> expect(url).to.contain i

        it 'should return the different state by default', ->
          expecting =
            page: 2
            per_page: 10
            q: 'testSearch'

          expect(collection.getState()).to.eql expecting

        it 'should return the entire state when desired', ->
          expecting =
            page: 2
            per_page: 10
            q: 'testSearch'
            order: 'desc'

          expect(collection.getState {}, inclDefaults: yes).to.eql expecting

        context 'then resetting to defaults', ->
          beforeEach ->
            collection.setState {}
            server.respond()

          it 'should set the state to the default empty object', ->
            expect(collection.state).to.eql {}

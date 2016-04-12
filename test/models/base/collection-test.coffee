define (require) ->
  Chaplin = require 'chaplin'
  ActiveSyncMachine = require 'mixins/active-sync-machine'
  Abortable = require 'mixins/abortable'
  SafeSyncCallback = require 'mixins/safe-sync-callback'
  ServiceErrorCallback = require 'mixins/service-error-callback'
  Collection = require 'models/base/collection'

  class MockCollection extends Collection
    DEFAULTS: _.extend {}, @::DEFAULTS, sort_by: 'attrA'
    syncKey: 'tests'
    urlRoot: '/test'

  testRequest = (expecting, request) ->
    _.each expecting, (expecting) ->
      expect(request.url).to.contain expecting

  describe 'Base Collection', ->
    server = null
    collection = null
    collectionClass = null
    data = [
      {attrA: 'A', attrB: 'A', id: 3}
      {attrA: 'B', attrB: 'Z', id: 1}
      {attrA: 'A', attrB: 'Z', id: 2}
      {attrA: 'Z', attrB: 'A', id: 0}
    ]

    beforeEach ->
      server = sinon.fakeServer.create()

    afterEach ->
      server.restore()

    context 'initialization', ->
      beforeEach ->
        collection = new MockCollection()

      afterEach ->
        collection.dispose()

      it 'should have proper mixins applied', ->
        funcs = _.functions Collection::
        expect(funcs).to.include.members _.functions ActiveSyncMachine::
        expect(funcs).to.include.members _.functions SafeSyncCallback::
        expect(funcs).to.include.members _.functions ServiceErrorCallback::
        expect(funcs).to.include.members _.functions Abortable::

    context 'sorting remotely', ->
      beforeEach ->
        collection = new MockCollection data

      afterEach ->
        collection.dispose()

      it 'should parse the server response correctly', ->
        results = collection.parse tests: data, count: 10
        expect(collection.count).to.eql 10
        expect(results).to.have.a.lengthOf 4
        expect(results[0]).to.not.be.empty

      context 'setting the state by force setting', ->
        beforeEach ->
          collection.setState {}
          server.respond()

        it 'should fetch from the server', ->
          expecting = ['/test', '?', 'sort_by=attrA', 'order=desc']
          testRequest expecting, server.requests[0]

      context 'setting the state by changing state', ->
        beforeEach ->
          collection.setState {sort_by: 'attrB'}
          server.respond()

        it 'should fetch from the server', ->
          expecting = ['/test', '?', 'sort_by=attrB', 'order=desc']
          testRequest expecting, server.requests[0]

    context 'changing', ->
      spy = null

      beforeEach ->
        collection = new MockCollection()
        spy = sinon.spy()
        collection.on 'stateChange', spy
        collection.setState {a:'b'}
        server.respond()

      afterEach ->
        collection.dispose()

      it 'should raise stateChange event', ->
        expect(spy).to.have.been.calledWith collection, {a:'b'}

    context 'on fetch fail', ->
      beforeEach ->
        collection = new MockCollection data
        collection.setState {}
        server.respondWith [500, {}, '{}']
        server.respond()

      afterEach ->
        collection.dispose()

      it 'should reset all existing items', ->
        expect(collection.length).to.equal 0

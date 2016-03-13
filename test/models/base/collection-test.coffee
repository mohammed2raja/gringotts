define (require) ->
  Chaplin = require 'chaplin'
  activeSyncMachine = require 'mixins/active-sync-machine'
  overrideXHR = require 'mixins/override-xhr'
  safeSyncCallback = require 'mixins/safe-sync-callback'
  serviceErrorCallback = require 'mixins/service-error-callback'
  Collection = require 'models/base/collection'

  class MockCollection extends Collection
    DEFAULTS: _.extend {}, Collection::DEFAULTS, {sort_by: 'attrA'}
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
        sinon.spy Collection::, 'activateSyncMachine'
        collection = new MockCollection()

      afterEach ->
        sinon.restore Collection::, 'activateSyncMachine'
        collection.dispose()

      it 'should have proper mixins applied', ->
        funcs = _.functions collection
        expect(funcs).to.include.members _.functions activeSyncMachine
        expect(funcs).to.include.members _.functions safeSyncCallback
        expect(funcs).to.include.members _.functions serviceErrorCallback
        expect(funcs).to.include.members _.functions overrideXHR

      it 'should activate SyncMachine', ->
        expect(Collection::activateSyncMachine).to.have.been.calledOnce

      context 'sync callbacks', ->
        beforeEach ->
          sinon.spy collection, 'serviceErrorCallback'
          sinon.spy collection, 'safeSyncCallback'
          sinon.spy collection, 'safeDeferred'
          collection.sync 'read', collection, {}
          server.respond()

        it 'should call serviceErrorCallback on sync', ->
          expect(collection.serviceErrorCallback).to.have.been.
            calledWith('read', collection, sinon.match.object).calledOnce

        it 'should call safeSyncCallback on sync', ->
          expect(collection.safeSyncCallback).to.have.been.
            calledWith('read', collection, sinon.match.object).calledOnce

        it 'should call safeDeferred on sync', ->
          expect(collection.safeDeferred).to.have.been.
            calledWith(sinon.match.object).calledOnce

      context 'overrideXHR', ->
        beforeEach ->
          sinon.spy collection, 'overrideXHR'
          collection.fetch()
          server.respond()

        it 'should overrideXHR on fetch', ->
          expect(collection.overrideXHR).to.have.been.
            calledWith(sinon.match.object).calledOnce

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

      context 'setting the state without a state change', ->
        beforeEach ->
          sinon.stub collection, 'fetch'
          collection.setState {}
          server.respond()
        afterEach ->
          collection.fetch.restore()

        it 'should not fetch from the server', ->
          expect(collection.fetch).to.have.not.beenCalled

      context.skip 'on multiple state sets', ->
        beforeEach ->
          sinon.stub collection, 'fetch'
          collection.setState {}
          collection.setState {}
          server.respond()
        afterEach ->
          collection.fetch.restore()

        it 'should not fetch after being synced', ->
          expect(collection.fetch).to.have.not.been.called

    context 'upon disposal', ->
      beforeEach ->
        collection = new MockCollection data
        sinon.stub collection, 'remove'
        collection.models[0].dispose()

      afterEach ->
        collection.remove.restore()

      it 'should remove a model upon disposal', ->
        expect(collection.remove).to.have.beenCalled

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

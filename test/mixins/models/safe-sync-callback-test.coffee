define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  SafeSyncCallback = require 'mixins/models/safe-sync-callback'

  class CollectionMock extends SafeSyncCallback Chaplin.Collection
    url: 'abc'

  describe 'SafeSyncCallback', ->
    server = null
    collection = null

    beforeEach ->
      server = sinon.fakeServer.create()
      collection = new CollectionMock()

    afterEach ->
      server.restore()
      collection.dispose()

    it 'should not fail sync without options', ->
      expect(-> collection.sync 'read', collection).to.not.throw Error

    context 'sync with a callback in options', ->
      expectCallback = (key, response) ->
        context key, ->
          customContext = null
          callback = null
          disposed = null

          beforeEach ->
            options = context: customContext
            options[key] = callback = sinon.spy()
            collection.fetch options
            collection.dispose() if disposed
            server.respondWith response
            server.respond()

          it 'should invoke callback', ->
            expect(callback).to.be.calledOnce

          context 'if disposed', ->
            before ->
              disposed = yes

            after ->
              disposed = null

            it 'should not invoke callback', ->
              expect(callback).to.not.be.calledOnce

          context 'with context', ->
            before ->
              customContext = {}

            after ->
              customContext = null

            it 'should invoke callback with custom context', ->
              expect(callback).to.be.calledOn customContext

      expectCallback 'success', '[]'
      expectCallback 'error', [500, {}, '{}']
      expectCallback 'complete', '[]'

    context 'sync with a promise callback', ->
      expectCallback = (key, response) ->
        context key, ->
          promise = null
          callback = null
          disposed = null

          beforeEach ->
            # force reject of promise to keep mocha going
            sinon.stub collection, 'safeSyncDeadPromise', ->
              $.Deferred().reject(status: 1000, 'fake', 'fake').promise()
            promise = collection.fetch()
            promise[key] callback = sinon.spy()
            collection.dispose() if disposed
            server.respondWith response
            server.respond()
            promise.catch ->

          it 'should invoke callback', ->
            expect(callback).to.be.calledOnce

          context 'if disposed', ->
            before ->
              disposed = yes

            after ->
              disposed = null

            it 'should not invoke callback', ->
              if key in ['done', 'then']
                expect(callback).to.not.be.calledOnce
              else
                expect(callback).to.be.calledWith \
                  sinon.match.has 'status', 1000

      expectCallback 'done', '[]'
      expectCallback 'fail', [500, {}, '{}']
      expectCallback 'always', '[]'
      expectCallback 'then', '[]'
      expectCallback 'catch', [500, {}, '{}']

    context 'aborting request', ->
      beforeEach ->
        collection.fetch().abort()
        return

      it 'should abort fetch request', ->
        expect(_.last server.requests).to.have.property 'aborted', true

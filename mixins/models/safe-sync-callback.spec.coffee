import Chaplin from 'chaplin'
import utils from 'lib/utils'
import SafeSyncCallback from 'mixins/models/safe-sync-callback'

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

  context 'aborting request', ->
    beforeEach ->
      collection.fetch().abort().catch ($xhr) ->
        $xhr unless $xhr.statusText is 'abort' # expected

    it 'should abort fetch request', ->
      expect(_.last server.requests).to.have.property 'aborted', true

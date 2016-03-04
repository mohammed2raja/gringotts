define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  safeSyncCallback = require 'mixins/safe-sync-callback'

  class MockCollection extends Chaplin.Collection
    _.extend @prototype, Chaplin.SyncMachine
    _.extend @prototype, safeSyncCallback

    sync: ->
      @safeSyncCallback.apply this, arguments
      super

  describe 'safeSyncCallback', ->
    server = null
    collection = null

    beforeEach ->
      server = sinon.fakeServer.create()
      collection = new MockCollection()
      collection.url = 'abc'
      collection.syncKey = 'pokemon'

    afterEach ->
      server.restore()
      collection.dispose()

    it 'should not error without options', ->
      try
        collection.sync 'read', collection
      catch error
        error = yes

      expect(error).not.to.exist

    describe 'for options callback', ->
      dispose = null
      callback = null
      spyCallback = null
      opts = null
      collection = null
      status = null

      afterDispose = (status) ->
        describe 'after dispose', ->
          before ->
            dispose = yes

          after ->
            dispose = null

          it "should not invoke the #{status} method", ->
            expect(spyCallback).not.to.be.called

      invokesCallback = (status) ->
        it "should invoke the #{status} method if the collection", ->
          expect(spyCallback).to.be.calledOnce

      beforeEach ->
        spyCallback ||= sinon.spy()
        (opts ||= {})[callback] = spyCallback
        collection.fetch opts
        status ||= 200
        collection.dispose() if dispose
        server.respondWith [status, {}, '{"count": 150, "pokemon": []}']
        server.respond()

      afterEach ->
        spyCallback = null

      describe 'success', ->
        before ->
          callback = 'success'

        invokesCallback 'success'
        afterDispose 'success'

      describe 'error', ->
        before ->
          callback = 'error'
          status = 404
        after ->
          status = null

        invokesCallback 'error'
        afterDispose 'error'

      describe 'complete', ->
        before ->
          callback = 'complete'

        invokesCallback 'complete'
        afterDispose 'complete'

        # Backbone `error` and `success` handlers
        # don't use `context` properly.
        describe 'with context', ->
          ctxCallback = null

          before ->
            ctxCallback = sinon.spy()
            context = {a: ctxCallback}
            spyCallback = -> @a()
            opts = {context}
          after ->
            opts = null
            spyCallback = null
            ctxCallback = null

          it 'should invoke the callback with the correct context', ->
            expect(ctxCallback).to.be.called

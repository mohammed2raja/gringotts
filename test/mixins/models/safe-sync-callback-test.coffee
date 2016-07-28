define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  SafeSyncCallback = require 'mixins/models/safe-sync-callback'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'

  class MockCollection extends utils.mix Chaplin.Collection
      .with ActiveSyncMachine, SafeSyncCallback

  describe 'SafeSyncCallback', ->
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
      collection = null
      status = null
      dispose = null
      opts = null
      callback = null
      spyCallback = null
      spyDone = null
      spyFail = null
      spyAlways = null

      promiseSpy = (status) ->
        if status is 'success'
          spyDone
        else if status is 'error'
          spyFail
        else if status is 'complete'
          spyAlways

      afterDispose = (status) ->
        describe 'after dispose', ->
          before ->
            dispose = yes

          after ->
            dispose = null

          it "should not invoke the #{status} method", ->
            expect(spyCallback).not.to.be.called

          it "should not invoke the #{status} promise handler", ->
            expect(promiseSpy status).not.to.be.called

      invokesCallback = (status) ->
        it "should invoke the #{status} method", ->
          expect(spyCallback).to.be.calledOnce

        it "should invoke the #{status} promise handler", ->
          expect(promiseSpy status).to.be.calledOnce

      beforeEach ->
        spyCallback ||= sinon.spy()
        (opts ||= {})[callback] = spyCallback
        spyDone = sinon.spy()
        spyFail = sinon.spy()
        spyAlways = sinon.spy()
        collection.fetch(opts).done(spyDone).fail(spyFail).always(spyAlways)
        status ||= 200
        collection.dispose() if dispose
        server.respondWith [status, {}, '{"count": 150, "pokemon": []}']
        server.respond()

      afterEach ->
        spyCallback = null
        spyDone = null
        spyFail = null
        spyAlways = null

      context 'success', ->
        before ->
          callback = 'success'

        invokesCallback 'success'
        afterDispose 'success'

      context 'error', ->
        before ->
          callback = 'error'
          status = 404
        after ->
          status = null

        invokesCallback 'error'
        afterDispose 'error'

      context 'complete', ->
        before ->
          callback = 'complete'

        invokesCallback 'complete'
        afterDispose 'complete'

        # Backbone `error` and `success` handlers
        # don't use `context` properly.
        context 'with context', ->
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

    context 'aborting request', ->
      $xhr = null

      beforeEach ->
        $xhr = collection.fetch()
        $xhr.abort()
        return # to avoid passing Deferred to mocha runner

      it 'should abort fetch request', ->
        expect(_.last(server.requests).aborted).to.be.equal true

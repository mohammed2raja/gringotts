define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  safeAjaxCallback = require 'mixins/safe-ajax-callback'
  require 'test/helpers/shared/progress-event-constructor'

  describe 'Safe AJAX callback mixin', ->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @collection = new Chaplin.Collection()
      @collection.url = 'red'
      @collection.syncKey = 'pokemon'
      advice.call @collection
      safeAjaxCallback.call @collection

    afterEach ->
      @server.restore()
      @collection.dispose()

    it 'does not error without options', ->
      try
        @collection.sync 'read', @collection
      catch error
        error = yes

      expect(error).not.to.exist

    describe 'for options callback', ->

      afterDispose = (status) ->
        describe 'after dispose', ->
          before ->
            @dispose = yes

          after ->
            delete @dispose

          it "does not invoke the #{status} method", ->
            expect(@spyCallback).not.to.be.called

      invokesCallback = (status) ->
        it "invokes the #{status} method if the collection", ->
          expect(@spyCallback).to.be.calledOnce

      beforeEach ->
        @spyCallback ||= sinon.spy()
        (@opts ||= {})[@callback] = @spyCallback
        @collection.fetch @opts
        @status ||= 200
        @collection.dispose() if @dispose
        @server.respondWith [@status, {},'{"count": 150, "pokemon": []}']
        @server.respond()

      afterEach ->
        @spyCallback = null

      describe 'success', ->
        before ->
          @callback = 'success'

        invokesCallback 'success'
        afterDispose 'success'

      describe 'error', ->
        before ->
          @callback = 'error'
          @status = 404
        after ->
          @status = null

        invokesCallback 'error'
        afterDispose 'error'

      describe 'complete', ->
        before ->
          @callback = 'complete'

        invokesCallback 'complete'
        afterDispose 'complete'

        # Backbone `error` and `success` handlers don't use `context` properly.
        describe 'with context', ->
          before ->
            @ctxCallback = sinon.spy()
            context = {a: @ctxCallback}
            @spyCallback = -> @a()
            @opts = {context}
          after ->
            @opts = null
            @spyCallback = null
            delete ctxCallback

          it 'invokes the callback with the correct context', ->
            expect(@ctxCallback).to.be.called

define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  ServiceErrorCallback = require 'mixins/models/service-error-callback'

  class MockCollection extends utils.mix Chaplin.Collection
      .with ActiveSyncMachine, ServiceErrorCallback

  describe 'ServiceErrorCallback', ->
    server = null
    collection = null

    beforeEach ->
      server = sinon.fakeServer.create()
      collection = new MockCollection()
      collection.url = 'hey'
      sinon.stub collection, 'trigger'
      sinon.spy collection, 'abortSync'

    afterEach ->
      server.restore()
      collection.dispose()

    it 'should do not error without options', ->
      try
        collection.sync 'read', collection
      catch error
        error = yes

      expect(error).not.to.exist

    context 'with a fetch', ->
      opts = null
      dispose = null

      beforeEach (done) ->
        opts ||= {}
        collection.fetch _.extend url: 'none', opts
        collection.dispose() if dispose
        done()

      context 'after responding', ->
        statusCode = null
        responseBody = null
        callbackSpy = null

        beforeEach ->
          responseBody = responseBody or '{"message": "down"}'
          statusCode = 418 unless typeof statusCode is 'number'
          server.respondWith [statusCode, {}, responseBody]
          server.respond()

        context 'with another 418 callback', ->
          before ->
            callbackSpy = sinon.spy()
            opts = statusCode: {418: callbackSpy}

          after ->
            opts = null
            callbackSpy = null

          it 'should invoke the callback', ->
            expect(callbackSpy).to.be.calledOnce
            expect(collection.trigger).to.be.calledWith 'service-unavailable'

        context 'with a different status callback', ->
          before ->
            callbackSpy = sinon.spy()
            statusCode = 500
            opts = statusCode: {500: callbackSpy}

          after ->
            callbackSpy = null
            opts = null
            statusCode = null

          it 'should invoke the callback', ->
            expect(callbackSpy).to.be.calledOnce

        context 'with an error callback', ->
          before ->
            callbackSpy = sinon.spy()
            opts = error: callbackSpy

          after ->
            opts = null
            callbackSpy = null

          it 'should invoke the callback', ->
            expect(callbackSpy).to.be.calledOnce
            expect(collection.trigger).to.be.calledWith 'service-unavailable'

          it 'should abort the sync', ->
            expect(collection.abortSync).to.be.calledOnce

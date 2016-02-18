define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  serviceUnavailable = require 'mixins/service-unavailable'

  describe 'Service unavailable mixin', ->
    server = null
    model = null

    beforeEach ->
      server = sinon.fakeServer.create()
      model = new Chaplin.Model()
      model.url = 'hey'
      advice.call model
      serviceUnavailable.call model
      sinon.stub model, 'publishEvent'
      sinon.stub model, 'trigger'

    afterEach ->
      server.restore()
      model.dispose()

    it 'should do not error without options', ->
      try
        model.sync 'read', model
      catch error
        error = yes

      expect(error).not.to.exist

    context 'with a fetch', ->
      opts = null
      syncMachine = null
      dispose = null

      beforeEach (done) ->
        opts ||= {}
        if syncMachine
          _.extend model, Chaplin.SyncMachine
          sinon.spy model, 'abortSync'

        model.fetch _.extend url: 'none', opts
        model.dispose() if dispose
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
            expect(model.trigger).to.be.calledWith 'service-unavailable'

        context 'with a canceled request', ->
          before ->
            statusCode = 0
          after ->
            statusCode = null

          it 'should do nothing', ->
            expect(model.trigger).not.to.be.calledWith 'service-unavailable'
            expect(model.publishEvent).not.to.be.called

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
            expect(model.trigger).to.be.calledWith 'service-unavailable'

          context 'and SyncMachine', ->
            before ->
              syncMachine = yes
            after ->
              syncMachine = null

            it 'should abort the sync', ->
              expect(model.abortSync).to.be.calledOnce

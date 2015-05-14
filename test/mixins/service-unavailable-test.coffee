define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  serviceUnavailable = require 'mixins/service-unavailable'

  describe 'Service unavailable mixin', ->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @model = new Chaplin.Model()
      @model.url = 'hey'
      advice.call @model
      serviceUnavailable.call @model
      ((window.I18n = {}).t = (text) -> text) if @i18n
      sinon.stub @model, 'publishEvent'
      sinon.stub @model, 'trigger'

    afterEach ->
      @server.restore()
      @model.dispose()
      delete window.I18n

    it 'does not error without options', ->
      try
        @model.sync 'read', @model
      catch error
        error = yes

      expect(error).not.to.exist

    describe 'with a fetch', ->
      beforeEach ->
        @opts ||= {}
        if @syncMachine
          _(@model).extend Chaplin.SyncMachine
          sinon.spy @model, 'abortSync'

        @model.fetch _.extend url: 'none', @opts
        @model.dispose() if @dispose

      describe 'after responding', ->
        beforeEach ->
          responseBody = @responseBody or '{"message": "down"}'
          @statusCode = 418 unless typeof @statusCode is 'number'
          @server.respondWith [@statusCode, {}, responseBody]
          @server.respond()

        it 'notifies user on error', ->
          expect(@model.publishEvent).to.be.calledOnce
          expect(@model.publishEvent).to.be.calledWith 'notify', 'down'

        describe 'with another 418 callback', ->
          before ->
            @callbackSpy = sinon.spy()
            @opts = statusCode: {418: @callbackSpy}

          after ->
            delete @opts
            delete @callbackSpy

          it 'invokes the callback', ->
            expect(@callbackSpy).to.be.calledOnce
            expect(@model.trigger).to.be.calledWith 'service-unavailable'

        describe 'with a canceled request', ->
          before ->
            @statusCode = 0
          after ->
            delete @statusCode

          it 'does nothing', ->
            expect(@model.trigger).not.to.be.calledWith 'service-unavailable'
            expect(@model.publishEvent).not.to.be.called

        describe 'with a different status callback', ->
          before ->
            @callbackSpy = sinon.spy()
            @statusCode = 500
            @opts = statusCode: {500: @callbackSpy}

          after ->
            _.each [
              'callbackSpy'
              'opts'
              'statusCode'
            ], (prop) ->
              delete @[prop]
            , this

          it 'invokes the callback', ->
            expect(@callbackSpy).to.be.calledOnce

          it 'publishes a default notification', ->
            expect(@model.publishEvent).to.be.calledWith 'notify',
              "There was a problem communicating with the server."

          describe 'with I18n', ->
            before ->
              @i18n = yes
            after ->
              delete @i18n

            it 'publishes an error notification', ->
              text = I18n.t 'error.notification'
              expect(@model.publishEvent).to.be.calledWith 'notify', text

        describe 'with an error callback', ->
          before ->
            @callbackSpy = sinon.spy()
            @opts = error: @callbackSpy

          after ->
            delete @opts
            delete @callbackSpy

          it 'invokes the callback', ->
            expect(@callbackSpy).to.be.calledOnce
            expect(@model.trigger).to.be.calledWith 'service-unavailable'

          describe 'and SyncMachine', ->
            before ->
              @syncMachine = yes
            after ->
              delete @syncMachine

            it 'aborts the sync', ->
              expect(@model.abortSync).to.be.calledOnce

        describe 'with bad JSON', ->
          before ->
            @responseBody = '<html></html>'

          after ->
            delete @responseBody

          it 'displays a default generic error', ->
            expect(@model.publishEvent).to.have.been.calledWith 'notify',
              "There was an error communicating with the server."

          describe 'with I18n', ->
            before ->
              @i18n = yes
            after ->
              delete @i18n

            it 'displays a generic error', ->
              text = I18n.t('error.service')
              expect(@model.publishEvent).to.have.been.calledWith(
                'notify', text
              )

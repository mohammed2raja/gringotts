define (require) ->
  Chaplin = require 'chaplin'
  Abortable = require 'mixins/models/abortable'

  class ModelMock extends Abortable Chaplin.Model
    url: '/abc'

  describe 'Abortable', ->
    sandbox = null
    model = null
    statusText = null
    errorSpy = null
    promise = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      sandbox.server.respondWith '{}'
      sandbox.spy Chaplin.Model::, 'sync'
      model = new ModelMock()
      promise = model.fetch error: (errorSpy = sinon.spy())
      return

    afterEach ->
      sandbox.restore()
      model.dispose()

    it 'should set the currentXHR property', ->
      expect(model.currentXHR).to.eql promise

    context 'on finish request', ->
      beforeEach ->
        sandbox.server.respond()
        promise

      it 'should delete currentXHR property', ->
        expect(model.currentXHR).to.be.undefined

    context 'on second fetch', ->
      promise2 = null

      beforeEach ->
        sandbox.spy model.currentXHR, 'abort'
        promise2 = model.fetch()
        return

      it 'should set the currentXHR property', ->
        expect(model.currentXHR).to.eql promise2

      it 'should abort the initial request', ->
        expect(promise.abort).to.have.been.calledOne

      context 'on third fetch', ->
        promise3 = null

        beforeEach ->
          sandbox.spy model.currentXHR, 'abort'
          promise3 = model.fetch()
          return

        it 'should set the currentXHR property', ->
          expect(model.currentXHR).to.eql promise3

        it 'should abort the initial request', ->
          expect(promise2.abort).to.have.been.calledOne

        context 'on finish request', ->
          beforeEach ->
            sandbox.server.respond()
            promise3

          it 'should delete currentXHR property', ->
            expect(model.currentXHR).to.be.undefined

    context 'on error', ->
      beforeEach ->
        options = Chaplin.Model::sync.lastCall.args[2]
        options.error (xhr = statusText: statusText or 'error')

      it 'should call original error handler', ->
        expect(errorSpy).to.have.been.calledOnce

      context 'on xhr abort', ->
        before ->
          statusText = 'abort'

        it 'should not call original error handler', ->
          expect(errorSpy).to.not.have.been.calledOnce

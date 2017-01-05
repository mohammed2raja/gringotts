define (require) ->
  Chaplin = require 'chaplin'
  Abortable = require 'mixins/models/abortable'

  class MockModel extends Abortable Chaplin.Model
    url: '/abc'

  describe 'Abortable', ->
    sandbox = null
    model = null
    errorSpy = null
    xhr = null
    statusText = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      sandbox.server.respondWith '{}'
      sandbox.spy Chaplin.Model::, 'sync'
      model = new MockModel()
      xhr = model.fetch error: (errorSpy = sinon.spy())
      return

    afterEach ->
      sandbox.restore()
      model.dispose()

    it 'should set the currentXHR property', ->
      expect(model.currentXHR).to.eql xhr

    context 'on finish request', ->
      beforeEach ->
        sandbox.server.respond()

      it 'should delete currentXHR property', ->
        expect(model.currentXHR).to.be.undefined

    context 'on second fetch', ->
      xhr2 = null

      beforeEach ->
        sandbox.spy model.currentXHR, 'abort'
        xhr2 = model.fetch()
        return

      it 'should set the currentXHR property', ->
        expect(model.currentXHR).to.eql xhr2

      it 'should abort the initial request', ->
        expect(xhr.abort).to.have.been.calledOne

      it 'should set xhr as error handled', ->
        expect(xhr.errorHandled).to.be.true

      context 'on third fetch', ->
        xhr3 = null

        beforeEach ->
          sandbox.spy model.currentXHR, 'abort'
          xhr3 = model.fetch()
          return

        it 'should set the currentXHR property', ->
          expect(model.currentXHR).to.eql xhr3

        it 'should abort the initial request', ->
          expect(xhr2.abort).to.have.been.calledOne

        it 'should set xhr as error handled', ->
          expect(xhr2.errorHandled).to.be.true

        context 'on finish request', ->
          beforeEach ->
            sandbox.server.respond()

          it 'should delete currentXHR property', ->
            expect(model.currentXHR).to.be.undefined

    context 'on error', ->
      beforeEach ->
        options = Chaplin.Model::sync.lastCall.args[2]
        options.error (xhr = statusText: statusText or 'error')

      it 'should call original error handler', ->
        expect(errorSpy).to.have.been.calledOnce

      it 'should not set xhr as error handled', ->
        expect(xhr.errorHandled).to.be.undefined

      context 'on xhr abort', ->
        before ->
          statusText = 'abort'

        it 'should not call original error handler', ->
          expect(errorSpy).to.not.have.been.calledOnce

        it 'should set xhr as error handled', ->
          expect(xhr.errorHandled).to.be.true

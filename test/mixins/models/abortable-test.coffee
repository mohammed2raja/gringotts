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

    beforeEach (done) ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      sandbox.spy Chaplin.Model::, 'sync'
      model = new MockModel()
      xhr = model.fetch error: (errorSpy = sinon.spy())
      done()

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
      beforeEach (done) ->
        sandbox.spy model.currentXHR, 'abort'
        model.fetch()
        done()

      it 'should abort the initial request', ->
        expect(model.currentXHR.abort).to.have.been.calledOne

      it 'should set xhr as error handled', ->
        expect(xhr.errorHandled).to.be.true

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

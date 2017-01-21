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
    request = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      sandbox.server.respondWith '{}'
      sandbox.spy Chaplin.Model::, 'sync'
      model = new ModelMock()
      promise = model.fetch error: (errorSpy = sinon.spy())
      request = _.last sandbox.server.requests
      return

    afterEach ->
      sandbox.restore()
      model.dispose()

    it 'should set the current_fetch property', ->
      expect(model.current_fetch).to.eql promise

    context 'on finish request', ->
      beforeEach ->
        sandbox.server.respond()
        promise

      it 'should delete current_fetch property', ->
        expect(model.current_fetch).to.be.undefined

    context 'on second fetch', ->
      promise2 = null
      request2 = null

      beforeEach ->
        sandbox.spy model.current_fetch, 'abort'
        promise2 = model.fetch()
        request2 = _.last sandbox.server.requests
        promise.catch ($xhr) ->
          $xhr unless $xhr.statusText is 'abort'

      it 'should set the current_fetch property', ->
        expect(model.current_fetch).to.eql promise2

      it 'should abort the initial request', ->
        expect(promise.abort).to.have.been.calledOne

      it 'should abort fetch request', ->
        expect(request).to.have.property 'aborted', true

      context 'on third fetch', ->
        promise3 = null

        beforeEach ->
          sandbox.spy model.current_fetch, 'abort'
          promise3 = model.fetch()
          promise2.catch ($xhr) ->
            $xhr unless $xhr.statusText is 'abort'

        it 'should set the current_fetch property', ->
          expect(model.current_fetch).to.eql promise3

        it 'should abort the initial request', ->
          expect(promise2.abort).to.have.been.calledOne

        it 'should abort fetch request', ->
          expect(request2).to.have.property 'aborted', true

        context 'on finish request', ->
          beforeEach ->
            sandbox.server.respond()
            promise3

          it 'should delete current_fetch property', ->
            expect(model.current_fetch).to.be.undefined

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

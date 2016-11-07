define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  ServiceErrorHandled = require 'mixins/models/service-error-handled'

  class MockCollection extends ServiceErrorHandled Chaplin.Collection

  describe 'ServiceErrorHandled', ->
    sandbox = null
    collection = null
    errorSpy = null
    xhr = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      collection = new MockCollection()
      sandbox.stub Chaplin.Collection::, 'sync'
      collection.fetch error: (errorSpy = sinon.spy())

    afterEach ->
      sandbox.restore()
      collection.dispose()

    context 'on error', ->
      beforeEach ->
        options = Chaplin.Collection::sync.lastCall.args[2]
        options.error (xhr = statusText: 'error')

      it 'should call original error handler', ->
        expect(errorSpy).to.have.been.calledOnce

      it 'should set xhr as errorHandled', ->
        expect(xhr.errorHandled).to.be.true

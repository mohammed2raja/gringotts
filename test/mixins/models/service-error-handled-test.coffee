define (require) ->
  Chaplin = require 'chaplin'
  ServiceErrorHandled = require 'mixins/models/service-error-handled'

  class MockCollection extends ServiceErrorHandled Chaplin.Collection

  describe 'ServiceErrorHandled', ->
    sandbox = null
    collection = null
    failHandler = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      collection = new MockCollection()
      sandbox.stub collection, 'sync', -> fail: (fn) -> failHandler = fn
      collection.fetch()

    afterEach ->
      sandbox.restore()
      collection.dispose()

    context 'on error', ->
      xhr = null

      beforeEach ->
        failHandler xhr = {}

      it 'should set xhr as errorHandled', ->
        expect(xhr.errorHandled).to.be.true

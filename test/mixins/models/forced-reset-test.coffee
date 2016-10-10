define (require) ->
  Chaplin = require 'chaplin'
  ForcedReset = require 'mixins/models/forced-reset'

  class MockCollection extends ForcedReset Chaplin.Collection
    url: '/test'

  describe 'ForcedReset', ->
    sandbox = null
    collection = null

    beforeEach (done) ->
      sandbox = sinon.sandbox.create useFakeServer: true
      collection = new MockCollection [{}, {}, {}]
      collection.fetch()
      done()

    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should have 3 items', ->
      expect(collection.length).to.equal 3

    context 'on fetch fail', ->
      beforeEach ->
        sandbox.server.respondWith [500, {}, '{}']
        sandbox.server.respond()

      it 'should reset all existing items', ->
        expect(collection.length).to.equal 0

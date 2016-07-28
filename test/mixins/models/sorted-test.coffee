define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  Sorted = require 'mixins/models/sorted'
  StatefulUrlParams = require 'mixins/models/stateful-url-params'

  class MockSortedCollection extends Sorted Chaplin.Collection
    urlRoot: '/test'

  describe 'Sorted mixin', ->
    sandbox = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      collection = new MockSortedCollection()

    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should be instantiated', ->
      expect(collection).to.be.instanceOf MockSortedCollection

    it 'should have proper mixins applied', ->
      expect(utils.instanceWithMixin collection, StatefulUrlParams).to.be.true

    context 'fetching', ->
      beforeEach ->
        collection.fetch()
        sandbox.server.respondWith [200, {}, JSON.stringify [{}, {}, {}]]
        sandbox.server.respond()

      it 'should query the server with the default state', ->
        request = _.last sandbox.server.requests
        expect(request.url).to.contain 'order=desc'

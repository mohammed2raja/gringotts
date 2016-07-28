define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  SyncKey = require 'mixins/models/sync-key'

  class MockSyncKeyCollection extends SyncKey Chaplin.Collection
    syncKey: 'someItems'
    url: '/test'

  describe 'SyncKey mixin', ->
    sandbox = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      collection = new MockSyncKeyCollection()
      collection.fetch()
      sandbox.server.respondWith [200, {}, JSON.stringify {
        count: 3
        someItems: [{}, {}, {}]
      }]
      sandbox.server.respond()


    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should be instantiated', ->
      expect(collection).to.be.instanceOf MockSyncKeyCollection

    it 'should parse response correctly', ->
      expect(collection.count).to.equal 3
      expect(collection.length).to.equal 3

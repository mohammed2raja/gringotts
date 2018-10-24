import Chaplin from 'chaplin'
import utils from 'lib/utils'
import SyncKey from 'mixins/models/sync-key'

class MockSyncKeyCollection extends SyncKey Chaplin.Collection
  syncKey: 'someItems'
  url: '/test'

describe 'SyncKey mixin', ->
  sandbox = null
  collection = null
  syncKey = null

  beforeEach ->
    sandbox = sinon.createSandbox useFakeServer: yes
    sandbox.server.respondWith [200, {}, JSON.stringify {
      someItems: [{}, {}, {}]
    }]
    collection = new MockSyncKeyCollection()
    collection.syncKey = syncKey if syncKey
    collection.fetch()


  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should be instantiated', ->
    expect(collection).to.be.instanceOf MockSyncKeyCollection

  it 'should parse response correctly', ->
    expect(collection.length).to.equal 3

  context 'when syncKey is a function', ->
    before ->
      syncKey = -> 'someItems'

    it 'should parse response correctly', ->
      expect(collection.length).to.equal 3

import Chaplin from 'chaplin'
import ForcedReset from './forced-reset'

class CollectionMock extends ForcedReset Chaplin.Collection
  url: '/test'

describe 'ForcedReset', ->
  sandbox = null
  collection = null
  promise = null
  catchSpy = null

  beforeEach ->
    sandbox = sinon.createSandbox useFakeServer: true
    sandbox.server.respondWith [500, {}, '{}']
    collection = new CollectionMock [{}, {}, {}]
    promise = collection.fetch().catch catchSpy = sinon.spy()
    return

  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should have 3 items', ->
    expect(collection.length).to.equal 3

  context 'on fetch fail', ->
    beforeEach ->
      promise

    it 'should reset all existing items', ->
      expect(collection.length).to.equal 0

    it 'should pass error down the chain', ->
      expect(catchSpy).to.have.been.calledOnce

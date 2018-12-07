import Chaplin from 'chaplin'
import ActiveSyncMachine from './active-sync-machine'
import SyncDeeply from './sync-deeply'

class ChildrenMock extends ActiveSyncMachine Chaplin.Collection
  url: '/test'
  fetch: ->
    @trigger 'request', this
    @trigger 'sync', this
    $.Deferred().resolve()

class ChildrenProblemMock extends ActiveSyncMachine Chaplin.Collection
  url: '/test'
  fetch: ->
    @trigger 'request', this
    @trigger 'error', this
    $.Deferred().resolve()

class CollectionMock extends SyncDeeply Chaplin.Collection
  constructor: ->
    super [
      new Chaplin.Model()
      new Chaplin.Model children: new ChildrenMock()
      new Chaplin.Model children: new ChildrenMock()
    ]

  fetch: ->
    @trigger 'request', this
    @trigger 'sync', this
    @fetchChildren()

describe 'SyncDeeply', ->
  sandbox = null
  collection = null

  beforeEach ->
    sandbox = sinon.createSandbox()
    collection = new CollectionMock()
    sandbox.spy collection, 'trigger'

  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should not trigger events', ->
    expect(collection.trigger).to.have.not.been.called

  expectStateOnFetch = (continueHandler) ->
    it 'should not be synced', ->
      expect(collection.isSynced()).to.be.false

    context 'on fetch', ->
      beforeEach ->
        sandbox.resetHistory()
        collection.fetch()

      it 'should be synced deep', ->
        expect(collection.isSynced()).to.be.true

      it 'should trigger synced event', ->
        expect(collection.trigger).to.have.been
          .calledWith 'synced', collection

      continueHandler() if continueHandler

  expectStateOnFetch ->
    context 'and adding an item', ->
      beforeEach ->
        collection.add \
          new Chaplin.Model children: new ChildrenMock()

      expectStateOnFetch()

    context 'and adding a problematic item', ->
      beforeEach ->
        collection.add \
          new Chaplin.Model(children: new ChildrenProblemMock()),
          at: 0

      it 'should not be synced', ->
        expect(collection.isSynced()).to.be.false

      context 'on fetch', ->
        beforeEach ->
          sandbox.resetHistory()
          collection.fetch()

        it 'should be synced deep', ->
          expect(collection.isSynced()).to.be.false

        it 'should not trigger synced event', ->
          expect(collection.trigger).to.have.not.been
            .calledWith 'synced'

        it 'should trigger unsynced event', ->
          expect(collection.trigger).to.have.been
            .calledWith 'unsynced', collection

    context 'and removing an item', ->
      beforeEach ->
        sandbox.resetHistory()
        model = collection.pop()
        model.get('children').fetch()

      it 'should not trigger synced event', ->
        expect(collection.trigger).to.have.not.been
          .calledWith 'synced'

    context 'and reset', ->
      beforeEach ->
        collection.reset [
          new Chaplin.Model children: new ChildrenMock()
          new Chaplin.Model children: new ChildrenMock()
          new Chaplin.Model()
          new Chaplin.Model()
        ]

      expectStateOnFetch()

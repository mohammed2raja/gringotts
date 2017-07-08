define (require) ->
  Chaplin = require 'chaplin'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  FilterGrouped = require 'mixins/models/filter-grouped'

  class ChildrenMock extends ActiveSyncMachine Chaplin.Collection
    url: '/test'
    fetch: ->
      @beginSync()
      @finishSync()
      @trigger 'sync'
      $.Deferred().resolve()

  class CollectionMock extends FilterGrouped ActiveSyncMachine \
      Chaplin.Collection
    constructor: ->
      super [
        new Chaplin.Model()
        new Chaplin.Model children: new ChildrenMock()
        new Chaplin.Model children: new ChildrenMock()
      ]

  describe 'FilterGrouped', ->
    sandbox = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      collection = new CollectionMock()
      sandbox.spy collection, 'trigger'

    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should not trigger events', ->
      expect(collection.trigger).to.have.not.been.called

    expectStateOnFetch = (continueHandler) ->
      it 'should not be synced deep', ->
        expect(collection.isSyncedDeep()).to.be.false

      context 'on fetch', ->
        beforeEach ->
          collection.beginSync()
          collection.finishSync()
          collection.fetchChildren()

        it 'should be synced deep', ->
          expect(collection.isSyncedDeep()).to.be.true

        it 'should trigger syncDeep event', ->
          expect(collection.trigger).to.have.been
            .calledWith 'syncDeep', collection

        continueHandler() if continueHandler

    expectStateOnFetch ->
      context 'and adding an item', ->
        beforeEach ->
          collection.add \
            new Chaplin.Model children: new ChildrenMock()

        expectStateOnFetch()

      context 'and removing an item', ->
        beforeEach ->
          collection.trigger.reset()
          model = collection.pop()
          model.get('children').fetch()

        it 'should not trigger syncDeep event', ->
          expect(collection.trigger).to.have.not.been.calledWith 'syncDeep'

      context 'and reset', ->
        beforeEach ->
          collection.reset [
            new Chaplin.Model children: new ChildrenMock()
            new Chaplin.Model children: new ChildrenMock()
            new Chaplin.Model()
            new Chaplin.Model()
          ]

        expectStateOnFetch()

    context 'on dispose', ->
      children = null

      beforeEach ->
        children = _.compact collection.pluck 'children'
        sandbox.restore()
        collection.dispose()

      it 'should have all item children disposed', ->
        children.forEach (c) -> expect(c.disposed).to.be.true

define (require) ->
  Chaplin = require 'chaplin'
  activeSyncMachine = require 'mixins/active-sync-machine'

  class MockCollection extends Chaplin.Collection
    _.extend @prototype, activeSyncMachine

    initialize: ->
      super
      @activateSyncMachine()

  describe 'activeSyncMachine', ->
    collection = null

    beforeEach ->
      collection = new MockCollection()
      sinon.stub collection, 'beginSync'
      sinon.stub collection, 'finishSync'
      sinon.stub collection, 'unsync'
      collection.trigger 'request', collection

    it 'should start the sync', ->
      expect(collection.beginSync).to.be.calledOnce

    context 'on response', ->
      beforeEach -> collection.trigger 'sync', collection

      it 'should complete the sync with finishSync', ->
        expect(collection.finishSync).to.be.calledOnce

    context 'on error', ->
      beforeEach -> collection.trigger 'error', collection

      it 'should complete the sync with unsync', ->
        expect(collection.unsync).to.be.calledOnce
define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  syncFetch = require 'mixins/sync-fetch'

  describe 'Sync fetch mixin', ->
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @collection = new Chaplin.Collection()
      _.extend @collection, Chaplin.SyncMachine
      @collection.url = 'foo'
      advice.call @collection
      syncFetch.call @collection
      sinon.stub @collection, 'beginSync'
      sinon.stub @collection, 'finishSync'
      @collection.fetch()

    afterEach ->
      @collection.dispose()
      @xhr.restore()

    it 'starts the sync', ->
      expect(@collection.beginSync).to.be.calledOnce

    it 'completes the sync properly', ->
      @collection.trigger 'sync'
      expect(@collection.finishSync).to.be.calledOnce

define (require) ->
  Chaplin = require 'chaplin'
  overrideXHR = require 'mixins/override-xhr'
  utils = require '../../lib/utils'

  class MockModel extends Chaplin.Model
    _.extend @prototype, Chaplin.SyncMachine
    _.extend @prototype, overrideXHR

    fetch: ->
      @overrideXHR super

  describe 'overrideXHR', ->
    server = null
    model = null
    currentXHR = null

    beforeEach ->
      server = sinon.fakeServer.create()
      model = new MockModel()
      model.url = 'abc'
      currentXHR = model.fetch()
      server.respond()

    afterEach ->
      server.restore()
      model.dispose()

    it 'should set the currentXHR property', ->
      expect(model.currentXHR).to.eql currentXHR

    context 'twice', ->
      beforeEach ->
        model.currentXHR = {abort: sinon.spy()}
        model.fetch()
        server.respond()

      it 'should abort the initial request', ->
        expect(model.currentXHR.abort).to.have.beenCalled

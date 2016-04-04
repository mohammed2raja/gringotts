define (require) ->
  Chaplin = require 'chaplin'
  utils = require '../../lib/utils'
  OverrideXHR = require 'mixins/override-xhr'
  ActiveSyncMachine = require 'mixins/active-sync-machine'

  class MockModel extends OverrideXHR ActiveSyncMachine Chaplin.Model

  describe 'OverrideXHR', ->
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
        expect(model.currentXHR.abort).to.have.been.calledOne

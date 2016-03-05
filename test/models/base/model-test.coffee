define (require) ->
  Chaplin = require 'chaplin'
  activeSyncMachine = require 'mixins/active-sync-machine'
  overrideXHR = require 'mixins/override-xhr'
  safeSyncCallback = require 'mixins/safe-sync-callback'
  Model = require 'models/base/model'

  describe 'Base Model', ->
    server = null
    model = null

    beforeEach ->
      server = sinon.fakeServer.create()
      sinon.spy Model::, 'activateSyncMachine'
      model = new Model()
      model.url = 'abc'

    afterEach ->
      server.restore()
      sinon.restore Model::, 'activateSyncMachine'
      model.dispose()

    it 'should have proper mixins applied', ->
      funcs = _.functions model
      expect(funcs).to.include.members _.functions Chaplin.SyncMachine
      expect(funcs).to.include.members _.functions activeSyncMachine
      expect(funcs).to.include.members _.functions safeSyncCallback
      expect(funcs).to.include.members _.functions overrideXHR

    it 'should activate SyncMachine', ->
      expect(Model::activateSyncMachine).to.have.been.calledOnce

    context 'sync callbacks', ->
      beforeEach ->
        sinon.spy model, 'safeSyncCallback'
        model.sync 'read', model, {}
        server.respond()

      it 'should call safeSyncCallback on sync', ->
        expect(model.safeSyncCallback).to.have.been.
          calledWith('read', model, sinon.match.object).calledOnce

    context 'overrideXHR', ->
      beforeEach ->
        sinon.spy model, 'overrideXHR'
        model.fetch()
        server.respond()

      it 'should overrideXHR on fetch', ->
        expect(model.overrideXHR).to.have.been.
          calledWith(sinon.match.object).calledOnce

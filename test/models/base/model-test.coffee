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
      expect(funcs).to.include.members _.functions activeSyncMachine
      expect(funcs).to.include.members _.functions safeSyncCallback
      expect(funcs).to.include.members _.functions overrideXHR

    it 'should activate SyncMachine', ->
      expect(Model::activateSyncMachine).to.have.been.calledOnce

    context 'sync callbacks', ->
      beforeEach ->
        sinon.spy model, 'safeSyncCallback'
        sinon.spy model, 'safeDeferred'
        model.sync 'read', model, {}
        server.respond()

      it 'should call safeSyncCallback on sync', ->
        expect(model.safeSyncCallback).to.have.been.
          calledWith('read', model, sinon.match.object).calledOnce

      it 'should call safeDeferred on sync', ->
        expect(model.safeDeferred).to.have.been.
          calledWith(sinon.match.object).calledOnce

    context 'overrideXHR', ->
      beforeEach ->
        sinon.spy model, 'overrideXHR'
        model.fetch()
        server.respond()

      it 'should overrideXHR on fetch', ->
        expect(model.overrideXHR).to.have.been.
          calledWith(sinon.match.object).calledOnce

    context 'safe save', ->
      deferred = null
      failSpy = null
      validationError = null

      beforeEach ->
        sinon.stub model, 'publishEvent'
        model.validate = -> validationError or 'Epic Fail!'
        failSpy = sinon.spy()
        deferred = model.save 'name', 'Eugene'
        deferred.fail failSpy
        return {} # to not pass failed deferred to mocha

      afterEach ->
        model.publishEvent.restore()

      it 'should return deferred for save', ->
        expect(deferred).to.be.not.false

      it 'should trigger fail promise', ->
        expect(failSpy).to.have.been.calledWith error: 'Epic Fail!'

      it 'should notify validation error', ->
        expect(model.publishEvent).to.have.been.calledWith 'notify',
          'Epic Fail!'

      context 'with complex validation error for current attr', ->
        before ->
          validationError = name: 'Epic Fail!'

        after ->
          validationError = null

        it 'should trigger fail promise', ->
          expect(failSpy).to.have.been.calledWith error: name: 'Epic Fail!'

        it 'should notify validation error', ->
          expect(model.publishEvent).to.have.been.calledWith 'notify',
            'Epic Fail!'

      context 'with complex validation error for random attr', ->
        before ->
          validationError = code: 'Crazy mistake', email: 'Epic Fail!'

        after ->
          validationError = null

        it 'should trigger fail promise', ->
          expect(failSpy).to.have.been.calledWith error: validationError

        it 'should notify validation error', ->
          expect(model.publishEvent).to.have.been.calledWith 'notify',
            'Crazy mistake'

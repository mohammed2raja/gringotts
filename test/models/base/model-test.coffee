define (require) ->
  Chaplin = require 'chaplin'
  ActiveSyncMachine = require 'mixins/active-sync-machine'
  Abortable = require 'mixins/abortable'
  SafeSyncCallback = require 'mixins/safe-sync-callback'
  Model = require 'models/base/model'

  describe 'Base Model', ->
    server = null
    model = null

    beforeEach ->
      server = sinon.fakeServer.create()
      model = new Model()
      model.url = 'abc'

    afterEach ->
      server.restore()
      model.dispose()

    it 'should have proper mixins applied', ->
      funcs = _.functions Model::
      expect(funcs).to.include.members _.functions ActiveSyncMachine::
      expect(funcs).to.include.members _.functions SafeSyncCallback::
      expect(funcs).to.include.members _.functions Abortable::

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

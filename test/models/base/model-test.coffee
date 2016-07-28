define (require) ->
  utils = require 'lib/utils'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  SafeSyncCallback = require 'mixins/models/safe-sync-callback'
  Abortable = require 'mixins/models/abortable'
  WithHeaders = require 'mixins/models/with-headers'
  Model = require 'models/base/model'

  describe 'Base Model', ->
    model = null

    beforeEach ->
      model = new Model()

    afterEach ->
      model.dispose()

    it 'should have proper mixins applied', ->
      expect(utils.instanceWithMixin model, ActiveSyncMachine).to.be.true
      expect(utils.instanceWithMixin model, SafeSyncCallback).to.be.true
      expect(utils.instanceWithMixin model, Abortable).to.be.true
      expect(utils.instanceWithMixin model, WithHeaders).to.be.true

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

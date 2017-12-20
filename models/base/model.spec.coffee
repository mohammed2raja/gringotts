import helper from 'lib/mixin-helper'
import ActiveSyncMachine from 'mixins/models/active-sync-machine'
import SafeSyncCallback from 'mixins/models/safe-sync-callback'
import ErrorHandled from 'mixins/models/error-handled'
import Abortable from 'mixins/models/abortable'
import WithHeaders from 'mixins/models/with-headers'
import Model from 'models/base/model'

describe 'Base Model', ->
  model = null

  beforeEach ->
    model = new Model()

  afterEach ->
    model.dispose()

  it 'should have proper mixins applied', ->
    expect(helper.instanceWithMixin model, ActiveSyncMachine).to.be.true
    expect(helper.instanceWithMixin model, SafeSyncCallback).to.be.true
    expect(helper.instanceWithMixin model, ErrorHandled).to.be.true
    expect(helper.instanceWithMixin model, Abortable).to.be.true
    expect(helper.instanceWithMixin model, WithHeaders).to.be.true

  context 'safe save', ->
    promise = null
    catchSpy = null
    validationError = null

    beforeEach ->
      model.validate = -> validationError or 'Epic Fail!'
      promise = model.save 'name', 'Eugene'
      promise.catch catchSpy = sinon.spy()

    it 'should return promise for save', ->
      expect(promise).to.be.ok

    it 'should return rejected promise', ->
      expect(catchSpy).to.have.been.calledWith \
        sinon.match.has 'message', 'Epic Fail!'

    context 'with complex validation error for current attr', ->
      before ->
        validationError = name: 'Epic Fail!'

      after ->
        validationError = null

      it 'should return rejected promise', ->
        expect(catchSpy).to.have.been.calledWith \
          sinon.match.has 'message', 'Epic Fail!'

    context 'with complex validation error for random attr', ->
      before ->
        validationError = code: 'Crazy mistake', email: 'Epic Fail!'

      after ->
        validationError = null

      it 'should return rejected promise', ->
        expect(catchSpy).to.have.been.calledWith \
          sinon.match.has 'message', 'Crazy mistake'

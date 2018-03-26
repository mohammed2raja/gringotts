import Chaplin from 'chaplin'
import ErrorHandled from 'mixins/models/error-handled'

class ModelMock extends ErrorHandled Chaplin.Model

describe 'ErrorHandled', ->
  sandbox = null
  model = null
  obj = null
  error = null
  errorHandled = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    sandbox.stub console, 'warn'
    model = new ModelMock()
    sandbox.spy model, 'trigger'
    if errorHandled
      model.on 'promise-error', (m, e) -> e.errorHandled = yes
    model.handleError.call {}, obj or error = new Error 'Oh jezz'

  afterEach ->
    sandbox.restore()
    model.dispose()

  it 'should trigger proper event', ->
    expect(model.trigger).to.have.been
      .calledWith 'promise-error', model, error

  it 'should notify that error was not properly handled', ->
    expect(console.warn).to.have.been.calledWith error

  context 'with http error', ->
    before ->
      obj = status: 500

    after ->
      obj = null

    it 'should notify that error was not properly handled', ->
      expect(console.warn).to.have.been
        .calledWith 'HTTP Error', obj.status, obj

  context 'when error was handled', ->
    before ->
      errorHandled = yes

    after ->
      errorHandled = null

    it 'should not do console logs', ->
      expect(console.warn).to.have.not.been.calledOnce

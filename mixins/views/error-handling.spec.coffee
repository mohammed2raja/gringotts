import Chaplin from 'chaplin'
import utils from 'lib/utils'
import ErrorHandling from 'mixins/views/error-handling'

class ViewMock extends ErrorHandling Chaplin.View

describe 'ErrorHandling', ->
  sandbox = null
  view = null
  model = null
  obj = null
  i18n = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    sandbox.stub utils, 'redirectTo'
    sandbox.stub console, 'warn'
    ((window.I18n = {}).t = (text) -> text) if i18n
    model = new Chaplin.Model()
    view = new ViewMock {model}
    sandbox.stub view, 'publishEvent'

  afterEach ->
    sandbox.restore()
    delete window.I18n
    model.dispose()
    view.dispose()

  context 'handling', ->
    beforeEach ->
      view.handleError obj

    context 'XHR errors', ->
      context 'with any http error', ->
        before ->
          obj = status: 500

        after ->
          obj = null

        it 'should send error notification', ->
          expect(view.publishEvent).to.have.been.calledWith 'notify'

        context 'and response JSON', ->
          before ->
            obj.responseText = JSON.stringify message: 'Operation failed!'

          after ->
            obj.responseText = null

          it 'should notify with message from response', ->
            expect(view.publishEvent).to.have.been.
              calledWith 'notify', 'Operation failed!'

        context 'with I18n', ->
          before ->
            i18n = yes

          after ->
            i18n = null

          it 'should notify with message from i18n', ->
            text = I18n.t 'error.notification'
            expect(view.publishEvent).to.have.been.calledWith 'notify', text

        context 'and bad response JSON', ->
          before ->
            obj.responseText = '<html></html>'

          after ->
            obj.responseText = null

          it 'should notify with default message', ->
            expect(view.publishEvent).to.have.been.calledWith 'notify',
              'There was a problem communicating with the server.'

    context 'generic errors', ->
      before ->
        obj = new Error 'Oh well'

      after ->
        obj = null

      it 'should log error into console', ->
        expect(console.warn).to.have.been.calledWith obj

  context 'handling model errors', ->
    error = null

    beforeEach ->
      model.trigger 'promise-error', model, error = new Error 'Oh snap'

    it 'should handle error', ->
      expect(error.errorHandled).to.be.true

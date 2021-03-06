import Chaplin from 'chaplin'
import Notifying from './notifying'

class ViewMock extends Notifying Chaplin.View

describe 'Notifying', ->
  sandbox = null
  view = null
  model = null
  obj = null
  i18n = null

  beforeEach ->
    sandbox = sinon.createSandbox()
    model = new Chaplin.Model()
    view = new ViewMock {model}
    sandbox.stub view, 'publishEvent'

  afterEach ->
    sandbox.restore()
    model.dispose()
    view.dispose()

  context 'notifying success', ->
    beforeEach ->
      view.notifySuccess 'Success!'

    it 'should publish notify event with dismiss options', ->
      expect(view.publishEvent).to.have.been.
        calledWith 'notify', 'Success!',
          classes: 'alert-success'
          navigateDismiss: yes

  context 'notifying error', ->
    beforeEach ->
      view.notifyError 'Error!'

    it 'should publish notify event with dismiss options', ->
      expect(view.publishEvent).to.have.been.
        calledWith 'notify', 'Error!',
          classes: 'alert-danger'
          navigateDismiss: yes

  context 'notifying with options', ->
    beforeEach ->
      view.notifySuccess 'Success!', navigateDismiss: no

    it 'should publish notify event with dismiss options', ->
      expect(view.publishEvent).to.have.been.
        calledWith 'notify', 'Success!',
          classes: 'alert-success'
          navigateDismiss: no

  context 'denotifying with options', ->
    beforeEach ->
      view.denotify 'Success!', classes: 'alert-danger'

    it 'should publish denotify event with options', ->
      expect(view.publishEvent).to.have.been.
        calledWith 'denotify', 'Success!', classes: 'alert-danger'

import Chaplin from 'chaplin'
import specHelper from '../lib/spec-helper'
import ErrorHandled from '../mixins/models/error-handled'
import ActiveSyncMachine from '../mixins/models/active-sync-machine'
import ProgressDialogView from './progress-dialog-view'
import templateMock from './progress-dialog-state-mock.spec.hbs'

class ModelMock extends ActiveSyncMachine ErrorHandled Chaplin.Model

describe 'ProgressDialogView', ->
  sandbox = null
  view = null
  viewConfig = null
  model = null
  onDone = null
  onCancel = null
  syncing = null
  transition = null
  appendToBody = null

  beforeEach ->
    sandbox = sinon.createSandbox()
    specHelper.stubModal sandbox, -> {transition}
    onDone = sinon.spy()
    onCancel = sinon.spy()
    model = new ModelMock()
    model.beginSync() if syncing
    config = _.extend {model, onDone, onCancel}, _.cloneDeep viewConfig
    view = new ProgressDialogView config
    $('body').append(view.$el) if appendToBody

  afterEach ->
    sandbox.restore()
    model.dispose()
    view.$el.remove() if appendToBody
    view.dispose()

  it 'should be initialized', ->
    expect(view).to.be.instanceOf ProgressDialogView
    expect(view.default.buttons).to.deep.
      include text: 'OK', className: 'btn-primary confirm-button'
    expect(view.error.title).to.equal 'Try again?'
    expect(view.error.text).to.equal "Hmm. That didn't seem to work."
    expect(view.success.html()).to.contain 'icon-misc-sign-check'
    expect(view.success.buttons).to.deep.
      include text: 'Okay', className: 'btn-primary confirm-button'

  it 'should have default view with proper classes', ->
    expect(view.$ '.default-state-view').to.have.class 'fade in'

  it 'should have default state button', ->
    expect(view.$ '.default-state-view .modal-footer .btn').to
      .exist.and.to.have.attr 'data-dismiss', 'modal'

  context 'with animations', ->
    before ->
      transition = true

    after ->
      transition = null

    it 'should have default view without fade class', ->
      expect(view.$ '.default-state-view').to.not.have.class 'fade'

    context 'on animation over', ->
      beforeEach ->
        view.$el.trigger 'shown.bs.modal'

      it 'should have default view with fade class', ->
        expect(view.$ '.default-state-view').to.have.class 'fade'

    context 'on hiding', ->
      beforeEach ->
        view.hide()

      it 'should have default view without fade class', ->
        expect(view.$ '.default-state-view').to.not.have.class 'fade'

  context 'on closing dialog', ->
    beforeEach ->
      view.hide()

    it 'should call onCancel handler', ->
      expect(onCancel).to.have.been.calledOnce

  context 'on model syncing', ->
    beforeEach ->
      model.beginSync()

    it 'should show loading progress', ->
      expect(view.$ '.progress-pulse.loading.fade.in').to.exist

    it 'should not switch to progress state', ->
      expect(view.state).to.equal 'default'
      expect(view.$ '.progress-state-view').to.not.have.class 'in'

    context 'on model unsynced', ->
      beforeEach ->
        model.unsync()

      it 'should hide loading progress', ->
        expect(view.$ '.progress-pulse.loading.fade.in').to.not.exist

      it 'should switch to error state', ->
        expect(view.state).to.equal 'error'
        expect(view.$ '.error-state-view').to.have.class 'in'

      context 'focus', ->
        before ->
          appendToBody = true

        after ->
          appendToBody = null

        it 'should focus confirm button', ->
          expect(view.$('.error-state-view .modal-footer button')[0] \
            is document.activeElement).to.be.true

      context 'on closing dialog', ->
        beforeEach ->
          view.$el.modal 'hide'

        it 'should call onCancel handler', ->
          expect(onCancel).to.have.been.calledOnce

    context 'on model synced', ->
      beforeEach ->
        model.finishSync()

      it 'should hide loading progress', ->
        expect(view.$ '.progress-pulse.loading.fade.in').to.not.exist

      it 'should switch to success state', ->
        expect(view.state).to.equal 'success'
        expect(view.$ '.success-state-view').to.have.class 'in'

      context 'focus', ->
        before ->
          appendToBody = true

        after ->
          appendToBody = null

        it 'should focus confirm button', ->
          expect(view.$('.success-state-view .modal-footer button')[0] \
            is document.activeElement).to.be.true

      context 'on closing dialog', ->
        beforeEach ->
          view.$el.modal 'hide'

        it 'should call onDone handler', ->
          expect(onDone).to.have.been.calledOnce

  context 'with syncing model', ->
    before ->
      syncing = true

    after ->
      syncing = null

    it 'should show loading progress', ->
      expect(view.$ '.progress-pulse.loading.fade.in').to.exist

    it 'should show default state', -> # because progress state isn't set
      expect(view.state).to.equal 'default'

  context 'with normally configured states', ->
    actionSpy = null
    tryAgainSpy = null

    before ->
      viewConfig =
        default:
          title: 'Doing This!'
          text: 'Do you want to do it?'
          buttons: [
            {text: 'Do it', className: 'btn-primary', click: _.noop}
          ]
        progress:
          title: 'Doing it right now'
          text: 'It is taking time'
        error:
          title: 'Could not do it!'
          text: 'So sorry, did not work out'
        success:
          title: 'Hooray'
          text: 'It was done!'

    after ->
      viewConfig = null

    beforeEach ->
      actionSpy = sinon.spy()
      tryAgainSpy = sinon.spy()
      view.default.buttons[0].click = actionSpy
      view.error.buttons[0].click = tryAgainSpy

    it 'should show correct default state', ->
      expect(view.$ '.default-state-view').to.exist
      expect(view.$ '.default-state-view .close').to.exist
      expect(view.$ '.default-state-view .modal-title').to.have
        .text 'Doing This!'
      expect(view.$ '.default-state-view .modal-body p')
        .to.have.text 'Do you want to do it?'
      expect(view.$ '.default-state-view .modal-footer .btn-primary').to
        .exist.and.to.not.have.attr 'data-dismiss', 'modal'

    context 'on action button click', ->
      beforeEach ->
        button = view.$ '.default-state-view .modal-footer .btn-primary'
        button.trigger 'click'

      it 'should invoke click handler', ->
        expect(actionSpy).to.have.been.calledWith sinon.match.object

    context 'on model syncing', ->
      beforeEach ->
        model.beginSync()

      it 'should show correct progress state', ->
        expect(view.$ '.progress-state-view.fade.in').to.exist
        expect(view.$ '.progress-state-view .modal-title')
          .to.have.text 'Doing it right now'
        expect(view.$ '.progress-state-view .modal-body p')
          .to.have.text 'It is taking time'
        expect(view.$ '.progress-state-view .modal-body .progress-pulse').to
          .exist

      context 'on model error', ->
        beforeEach ->
          model.handleError {}

        it 'should show correct success state', ->
          expect(view.$ '.error-state-view.fade.in').to.exist
          expect(view.$ '.error-state-view .modal-title')
            .to.have.text 'Could not do it!'
          expect(view.$ '.error-state-view .modal-body p')
            .to.have.text 'So sorry, did not work out'

        context 'on try again button click', ->
          beforeEach ->
            button = view.$ '.error-state-view .modal-footer .btn-primary'
            button.trigger 'click'

          it 'should invoke click handler', ->
            expect(tryAgainSpy).to.have.been.calledWith sinon.match.object

      context 'on model synced', ->
        beforeEach ->
          model.finishSync()

        it 'should show correct success state', ->
          expect(view.$ '.success-state-view.fade.in').to.exist
          expect(view.$ '.success-state-view .modal-title')
            .to.have.text 'Hooray'
          expect(view.$ '.success-state-view .modal-body h1')
            .to.have.text 'It was done!'
          expect(view.$ '.success-state-view .modal-footer .btn-primary').to
            .exist.and.to.have.attr 'data-dismiss', 'modal'

    context 'with syncing model', ->
      before ->
        syncing = true

      after ->
        syncing = null

      it 'should show progress state', ->
        expect(view.state).to.equal 'progress'

      it 'should have progress state without fade', ->
        expect(view.$ '.progress-state-view').to.have.class 'fade in'

  context 'with custom template states', ->
    before ->
      html = templateMock
      viewConfig =
        default: text: html
        progress: text: html
        error: text: html
        success: text: html

    after ->
      viewConfig = null

    it 'should have propert rendered states', ->
      title = 'Epic Header'
      text = 'Cool custom state'
      ['default', 'progress', 'error', 'success'].forEach (s) ->
        expect(view.$ ".#{s}-state-view .modal-body h1").to.have.text title
        expect(view.$ ".#{s}-state-view .modal-body p").to.have.text text

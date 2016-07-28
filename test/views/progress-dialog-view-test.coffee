define (require) ->
  Chaplin = require 'chaplin'
  modalHelpers = require 'test/helpers/modal-helpers'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  ProgressDialogView = require 'views/progress-dialog-view'
  templates = require 'test/templates'

  class MockModel extends ActiveSyncMachine Chaplin.Model

  describe 'ProgressDialogView', ->
    view = null
    viewConfig = null
    model = null
    onDone = null
    onCancel = null
    syncing = null
    transition = null

    beforeEach ->
      modalHelpers.stubModal -> {transition}
      onDone = sinon.spy()
      onCancel = sinon.spy()
      model = new MockModel()
      model.beginSync() if syncing
      view = new ProgressDialogView _.extend {model, onDone, onCancel},
        viewConfig

    afterEach ->
      try view.dispose()
      $.fn.modal.restore()
      model.dispose()

    it 'should be initialized', ->
      expect(view).to.be.instanceOf ProgressDialogView
      expect(view.default.buttons).to.
        include text: 'OK', className: 'btn-action'
      expect(view.error.title).to.eq "Hmm. That didn't seem to work. Try again?"
      expect(view.error.buttons).to.
        include text: 'Cancel', className: 'btn-cancel'
      expect(view.success.html()).to.contain 'icon-misc-sign-check'
      expect(view.success.buttons).to.
        include text: 'Okay', className: 'btn-action'

    it 'should have default view with proper classes', ->
      expect(view.$ '.default-view').to.have.class 'fade in'

    it 'should have default state button', ->
      expect(view.$ '.default-view .modal-footer .btn').to.exist

    context 'with animations', ->
      before ->
        transition = true

      after ->
        transition = null

      it 'should have default view without fade class', ->
        expect(view.$ '.default-view').to.not.have.class 'fade'

      context 'on animation over', ->
        beforeEach ->
          view.$el.trigger 'shown.bs.modal'

        it 'should have default view with fade class', ->
          expect(view.$ '.default-view').to.have.class 'fade'

      context 'on hiding', ->
        beforeEach ->
          view.$el.modal 'hide'

        it 'should have default view without fade class', ->
          expect(view.$ '.default-view').to.not.have.class 'fade'

    context 'on closing dialog', ->
      beforeEach ->
        view.$el.modal 'hide'

      it 'should call onCancel handler', ->
        expect(onCancel).to.have.been.calledOnce

      it 'should be disposed', ->
        expect(view.disposed).to.be.true

    context 'on model syncing', ->
      beforeEach ->
        model.beginSync()

      it 'should show loading progress', ->
        expect(view.$ '.progress-pulse.loading.fade.in').to.exist

      it 'should not switch to progress state', ->
        expect(view.state).to.equal 'default'
        expect(view.$ '.progress-view').to.not.have.class 'in'

      context 'on model error', ->
        xhr = null

        beforeEach ->
          xhr = {}
          model.trigger 'error', model, xhr

        it 'should hide loading progress', ->
          expect(view.$ '.progress-pulse.loading.fade.in').to.not.exist

        it 'should switch to error state', ->
          expect(view.state).to.equal 'error'
          expect(view.$ '.error-view').to.have.class 'in'

        it 'should handle xhr error', ->
          expect(xhr.errorHandled).to.be.true

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
          expect(view.$ '.success-view').to.have.class 'in'

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
              {text: 'Cancel', className: 'btn-cancel'}
              {text: 'Do it', className: 'btn-action', click: _.noop}
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

      beforeEach ->
        actionSpy = sinon.spy()
        tryAgainSpy = sinon.spy()
        view.default.buttons[1].click = actionSpy
        view.error.buttons[1].click = tryAgainSpy

      it 'should show correct default state', ->
        expect(view.$ '.default-view').to.exist
        expect(view.$ '.default-view .modal-title').to.have.text 'Doing This!'
        expect(view.$ '.default-view .modal-body p')
          .to.have.text 'Do you want to do it?'
        expect(view.$ '.default-view .modal-footer .btn-cancel').to.exist
        expect(view.$ '.default-view .modal-footer .btn-action').to.exist

      context 'on action button click', ->
        beforeEach ->
          view.$('.default-view .modal-footer .btn-action').trigger 'click'

        it 'should invoke click handler', ->
          expect(actionSpy).to.have.been.calledWith sinon.match.object

      context 'on model syncing', ->
        beforeEach ->
          model.beginSync()

        it 'should show correct progress state', ->
          expect(view.$ '.progress-view.fade.in').to.exist
          expect(view.$ '.progress-view .modal-title')
            .to.have.text 'Doing it right now'
          expect(view.$ '.progress-view .modal-body p')
            .to.have.text 'It is taking time'
          expect(view.$ '.progress-view .modal-body .progress-pulse').to.exist

        context 'on model error', ->
          beforeEach ->
            model.trigger 'error', model, {}

          it 'should show correct success state', ->
            expect(view.$ '.error-view.fade.in').to.exist
            expect(view.$ '.error-view .modal-title')
              .to.have.text 'Could not do it!'
            expect(view.$ '.error-view .modal-body p')
              .to.have.text 'So sorry, did not work out'

          context 'on try again button click', ->
            beforeEach ->
              view.$('.error-view .modal-footer .btn-action').trigger 'click'

            it 'should invoke click handler', ->
              expect(tryAgainSpy).to.have.been.calledWith sinon.match.object

        context 'on model synced', ->
          beforeEach ->
            model.finishSync()

          it 'should show correct success state', ->
            expect(view.$ '.success-view.fade.in').to.exist
            expect(view.$ '.success-view .modal-title')
              .to.have.text 'Hooray'
            expect(view.$ '.success-view .modal-body h1')
              .to.have.text 'It was done!'

      context 'with syncing model', ->
        before ->
          syncing = true

        after ->
          syncing = null

        it 'should show progress state', ->
          expect(view.state).to.equal 'progress'

        it 'should have progress state without fade', ->
          expect(view.$ '.progress-view').to.have.class 'fade in'

    context 'with custom template states', ->
      before ->
        html = templates['progress-dialog-state']
        viewConfig =
          default: text: html
          progress: text: html
          error: text: html
          success: text: html

      it 'should have propert rendered states', ->
        title = 'Epic Header'
        text = 'Cool custom state'
        ['default', 'progress', 'error', 'success'].forEach (s) ->
          expect(view.$ ".#{s}-view .modal-body h1").to.have.text title
          expect(view.$ ".#{s}-view .modal-body p").to.have.text text

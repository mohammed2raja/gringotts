import Chaplin from 'chaplin'
import specHelper from 'lib/spec-helper'
import ModalView from 'views/base/modal-view'
import NotificationsView from 'views/notifications-view'

class MockModal extends ModalView
  template: require './modal.spec.hbs'

describe 'ModalView', ->
  sandbox = null
  view = null
  transition = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    specHelper.stubModal sandbox, -> {transition}
    MockModal::autoAttach = no
    view = new MockModal()

  afterEach ->
    view.dispose()
    MockModal::autoAttach = yes
    sandbox.restore()

  context 'after modal is attached', ->
    shownSpy = null
    appendToBody = null
    noDefaultAutofocus = null

    beforeEach ->
      view.on 'shown', shownSpy = sinon.spy()
      view.$('[autofocus]').remove() if noDefaultAutofocus
      $('body').append(view.$el) if appendToBody
      view.attach()

    afterEach ->
      view.$el.remove() if appendToBody

    it 'should add scroll classes', ->
      expect($ 'body').to.have.class 'no-scroll'

    it 'should have modal class set', ->
      expect(view.$el).to.have.attr 'class', 'modal fade in'

    it 'should trigger shown event', ->
      expect(shownSpy).to.have.been.calledOnce

    context 'focus', ->
      before ->
        appendToBody = true

      after ->
        appendToBody = null

      it 'should autofocus input element', ->
        expect(view.$('.test-focus')[0] is document.activeElement).to.be.true

      context 'modal does not have autofocus elements', ->
        before ->
          noDefaultAutofocus = true

        after ->
          noDefaultAutofocus = null

        it 'should autofocus button element', ->
          expect(view.$('.submit-button')[0] is document.activeElement)
            .to.be.true

    context 'and then hiding modal', ->
      hiddenSpy = null

      beforeEach ->
        view.on 'hidden', hiddenSpy = sinon.spy()
        view.hide()

      it 'should remove scroll classes', ->
        expect($ 'body').not.to.have.class 'no-scroll'

      it 'should trigger hidden event', ->
        expect(hiddenSpy).to.have.been.calledOnce

      context 'notifying errors with modal hidden', ->
        notifications = null

        beforeEach ->
          sinon.spy view, 'publishEvent'
          view.notifyError('error message')
          notifications = view.subview('notifications')

        afterEach ->
          view.publishEvent.restore()

        it 'should not set notifications subview', ->
          expect(notifications).not.to.exist

        it 'should add notification through publishing notify event', ->
          expect(view.publishEvent).to.been
            .calledWith 'notify', 'error message',
              classes: 'alert-danger'
              navigateDismiss: yes

      context 'and then show again', ->
        beforeEach ->
          view.show()

        it 'should trigger shown event', ->
          expect(shownSpy).to.have.been.calledTwice

        context 'notifying errors', ->
          notifications = null

          beforeEach ->
            view.notifyError('error message')
            notifications = view.subview('notifications')

          it 'should set notifications subview', ->
            expect(notifications).to.be.instanceOf NotificationsView

          it 'should add error message to notifications', ->
            expect(notifications.collection).to.have.length 1

          it 'should have correct message', ->
            message = notifications.collection.models[0].get 'message'
            expect(message).to.eql 'error message'

    context 'on disposing', ->
      beforeEach ->
        transition = true
        view.dispose()

      afterEach ->
        transition = null

      it 'should hide modal after disposed', ->
        expect($.fn.modal).to.have.been.calledWith 'hide'

      it 'should not be disposed before modal is hidden', ->
        expect(view.disposed).to.be.false

      context 'and modal was hidden', ->
        beforeEach ->
          view.$el.trigger 'hidden.bs.modal'

        it 'should dispose modal view', ->
          expect(view.disposed).to.be.true

  context 'on disposing', ->
    beforeEach ->
      view.dispose()

    it 'should be disposed', ->
      expect(view.disposed).to.be.true

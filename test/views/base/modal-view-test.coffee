define (require) ->
  Chaplin = require 'chaplin'
  modalHelpers = require 'test/helpers/modal-helpers'
  ModalView = require 'views/base/modal-view'

  class MockModal extends ModalView
    template: 'modal-test'
    templatePath: 'test/templates'

  describe 'ModalView', ->
    view = null
    model = null
    transition = null

    beforeEach ->
      modalHelpers.stubModal -> {transition}
      view = new MockModal {model}

    afterEach ->
      try view.dispose() unless view.disposed
      $.fn.modal.restore()

    it 'should add scroll classes', ->
      expect($ 'body').to.have.class 'no-scroll'

    it 'should have modal class set', ->
      expect(view.$el).to.have.attr 'class', 'modal fade in'

    context 'and then hiding modal', ->
      beforeEach ->
        view.$el.modal 'hide'

      it 'should remove scroll classes', ->
        expect($ 'body').not.to.have.class 'no-scroll'

      it 'should dispose itself', ->
        expect(view.disposed).to.be.true

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
          transition = null
          view.$el.modal 'hide'

        it 'should dispose modal view', ->
          expect(view.disposed).to.be.true

    context 'with model after modal is hidden', ->
      before ->
        model = new Chaplin.Model()

      after ->
        model = null

      beforeEach ->
        view.$el.modal 'hide'

      it 'should not dispose itself', ->
        expect(view.disposed).to.be.false

      context 'if disposed is called from outside', ->
        beforeEach ->
          model.dispose()

        it 'should dispose itself', -> # since modal is hidden already
          expect(view.disposed).to.be.true

    context 'with model on disposing', ->
      before ->
        model = new Chaplin.Model()

      after ->
        model = null

      beforeEach ->
        transition = true
        view.dispose()

      it 'should hide modal after disposed', ->
        expect($.fn.modal).to.have.been.calledWith 'hide'

      it 'should not dispose itself', -> # since it's still visible
        expect(view.disposed).to.be.false

      context 'after modal is hidden', ->
        beforeEach ->
          transition = null
          view.$el.modal 'hide'

        it 'should dispose itself', ->
          expect(view.disposed).to.be.true

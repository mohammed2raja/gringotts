define (require) ->
  Chaplin = require 'chaplin'
  ModalView = require 'views/base/modal-view'

  class MockModal extends ModalView
    template: 'modal-test'
    templatePath: 'test/templates'

  describe 'ModalView', ->
    view = null
    model = null

    beforeEach ->
      sinon.stub $.fn, 'modal'
      view = new MockModal {model}
      sinon.spy view, 'dispose'

    afterEach ->
      $.fn.modal.restore()
      unless view.disposed
        view.dispose.restore()
        view.dispose()

    context 'showing modal', ->
      beforeEach ->
        view.$el.trigger 'shown.bs.modal'

      it 'should add scroll classes', ->
        expect($ 'body').to.have.class 'no-scroll'

      it 'should have modal class set', ->
        expect(view.$el).to.have.attr 'class', 'modal'

      context 'on second render', ->
        beforeEach ->
          view.render()

        it 'should have only one modal class', ->
          expect(view.$el).to.have.attr 'class', 'modal'

      context 'and then hiding modal', ->
        beforeEach ->
          view.$el.trigger 'hidden.bs.modal'

        it 'should remove scroll classes', ->
          expect($ 'body').not.to.have.class 'no-scroll'

        it 'should hide itself', ->
          expect($.fn.modal).to.have.been.calledWith 'hide'

        it 'should dispose itself', ->
          expect(view.dispose).to.have.been.calledOnce

    context 'on disposing', ->
      beforeEach ->
        view.dispose()

      it 'should hide modal after disposed', ->
        expect($.fn.modal).to.have.been.calledWith 'hide'

    context 'with model', ->
      before ->
        model = new Chaplin.Model()

      after ->
        model = null

      beforeEach ->
        view.$el.trigger 'hidden.bs.modal'

      it 'should hide itself', ->
        expect($.fn.modal).to.have.been.calledWith 'hide'

      it 'should not dispose itself', ->
        expect(view.dispose).to.have.not.been.called

    context 'when forcing one instance', ->
      anotherView = null

      beforeEach ->
        $('body').append $('<div></div>').addClass('modal-test')
        anotherView = new MockModal forceOneInstance: true

      afterEach ->
        $('div.modal-test').remove()
        anotherView = null

      it 'should not create modal dialog', ->
        expect(anotherView.disposed).to.be.true

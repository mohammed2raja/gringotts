define (require) ->
  ModalView = require 'views/base/modal-view'

  describe 'ModalView', ->
    beforeEach ->
      sinon.stub $.fn, 'modal'
      sinon.stub ModalView::, 'render'
      @view = new ModalView {@template}

    afterEach ->
      @view.dispose() unless @view.disposed
      ModalView::render.restore()
      $.fn.modal.restore()

    context 'showing modal', ->
      beforeEach -> @view.$el.trigger 'shown.bs.modal'

      it 'should add scroll classes', ->
        expect($ 'body').to.have.class 'no-scroll'

      context 'and then hiding modal', ->
        beforeEach -> @view.$el.trigger 'hidden.bs.modal'

        it 'should remove scroll classes', ->
          expect($ 'body').not.to.have.class 'no-scroll'

        it 'should dispose itself', ->
          expect($.fn.modal).to.have.been.calledWith 'hide'

    context 'on disposing', ->
      beforeEach -> @view.dispose()

      it 'should hide modal after disposed', ->
        expect($.fn.modal).to.have.been.calledWith 'hide'

    context 'when forcing one instance', ->
      beforeEach ->
        @template = 'foo-template'
        $('body').append $('<div></div>').addClass(@template)
        @anotherView = new ModalView {@template, forceOneInstance: true}
      afterEach ->
        $("div.#{@template}").remove()
        delete @template
        delete @anotherView

      it 'should not create modal dialog', ->
        expect(@anotherView.disposed).to.be.true

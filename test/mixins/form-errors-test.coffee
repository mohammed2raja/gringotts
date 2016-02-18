define (require) ->
  Chaplin = require 'chaplin'
  formErrors = require 'mixins/form-errors'

  describe 'Form error mixin', ->
    view = null

    beforeEach ->
      view = new Chaplin.View()
      view.getTemplateFunction = ->
        -> '''
          <form>
            <input type="text" id="goblin-ghost">
            <input type="text" class="goblin-ghost">
            <input type="text" name="goblin-ghost">
            <input type="text" data-attr="goblin-ghost">
          </form>
        '''
      formErrors.call view
      view.render()

    afterEach ->
      view.dispose()

    it 'places generic errors at the beginning of the form', ->
      view.genericError 'KABLOOM!'
      expect(view.$ 'form > .help-block:first').to.exist
        .and.to.contain 'KABLOOM!'

    it 'puts specific errors after the input', ->
      view.specificError '#goblin-ghost', 'BOO!'
      expect(view.$ '#goblin-ghost + .help-block').to.exist
        .and.to.contain 'BOO!'

    it 'uses the name attribute for specific errors by default', ->
      view.parseErrors "goblin-ghost": "GOTYA!"
      expect(view.$ '[name=goblin-ghost] + .help-block').to.exist
        .and.to.contain 'GOTYA!'

    it 'fires an event before processing specific errors', ->
      formErrors.call view, specificErrors: yes
      errors = sinon.spy()
      sinon.spy view, 'trigger'
      sinon.stub view, 'specificError'
      view.parseErrors errors
      expect(view.trigger).to.be.calledWith 'specificErrors:before', errors

    it 'processes an array of generic errors properly', ->
      sinon.spy view, 'genericError'
      view.parseErrors generic: ['BOOYAH!', 'HEY!']
      expect(view.genericError).to.be.calledTwice
      expect(view.genericError).to.be.calledWith 'BOOYAH!'
      expect(view.genericError).to.be.calledWith 'HEY!'

    describe 'displays generic error message', ->
      retVal = null

      beforeEach ->
        sinon.stub(view, 'genericError').returns 'AHH!'
      afterEach ->
        expect(retVal).to.equal 'AHH!'

      it 'if errors is falsy', ->
        retVal = view.parseErrors()
        expect(view.genericError)
          .to.be.calledWith 'There was a problem. Please try again.'

      it 'if errors are empty', ->
        retVal = view.parseErrors {}
        expect(view.genericError)
          .to.be.calledWith 'There was a problem. Please try again.'

      it 'that is customizable', ->
        formErrors.call view, genericErrMsg: 'HAHA!'
        sinon.stub(view, 'genericError').returns 'AHH!'
        retVal = view.parseErrors()
        expect(view.genericError)
          .to.be.calledWith 'HAHA!'

    describe 'displays specific error message', ->
      selector = null

      afterEach ->
        view.parseErrors "goblin-ghost": "GONNA GET YOU!"
        expect(view.$ "#{selector} + .help-block").to.exist
          .and.to.contain 'GONNA GET YOU!'

      it 'near the ID when specified', ->
        formErrors.call view, inputAttr: 'id'
        selector = '#goblin-ghost'

      it 'near the class when specified', ->
        formErrors.call view, inputAttr: 'class'
        selector = '.goblin-ghost'

      it 'near the custom attribute specified', ->
        formErrors.call view, inputAttr: 'data-attr'
        selector = '[data-attr=goblin-ghost]'

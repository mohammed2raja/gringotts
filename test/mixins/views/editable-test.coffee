define (require) ->
  Chaplin = require 'chaplin'
  FakeModel = require 'test/helpers/validate-model'
  FakeView = require 'test/helpers/editable-view'

  describe 'Editable', ->
    model = null
    view = null
    success = null
    error = null
    errorClass = undefined
    opts = null
    customOpts = null
    enter = null
    field = null
    click = null
    value = null
    event = null

    # TODO: this is a duplicate from editable-callbacks-test
    setupEditableBefore = ->
      field ||= '.name-field'
      click ||= '.edit-name'
      view.$(click).click()
      value = 'Peter Bishop' if value is null
      view.$(field).text value
      e = if event is null then enter else event
      view.$(field).trigger e

    setupEditableAfter = ->
      # FIXME: since error state is tracked globally it has to be reset after
      # each test. it should not be tracked globally
      view.$(field).text('Peter Bishop').trigger enter
      click = null
      field = null

    beforeEach ->
      sinon.stub document, 'execCommand'
      model = new FakeModel
        name: 'Olivia Dunham'
        email: 'odunhameffbeeeye.com'
        url: 'http://dunham.com'
      view = new FakeView {model}
      success = sinon.spy()
      error = sinon.spy()
      opts = _.extend {
        success
        error
        errorClass
      }, customOpts
      view.setupEditable '.edit-name', '.name-field', opts
      enter = $.Event 'keydown', keyCode: 13

    afterEach ->
      enter = null
      view.dispose()
      model.dispose()
      model = null
      view = null
      opts = null
      document.execCommand.restore()

    it 'should attache a click handler', ->
      view.$('.edit-name').click()
      expect(view.$field()).to.have.attr 'contenteditable'
      expect(document.execCommand).to.have.been.called

    context 'optional model defined', ->
      otherModel = null

      before ->
        otherModel = new FakeModel {test:'test'}
        sinon.spy otherModel, 'validate'
        customOpts =
          model: otherModel
      beforeEach setupEditableBefore
      afterEach setupEditableAfter

      after ->
        customOpts = null
        otherModel.dispose()
        otherModel = null

      it 'should make editable', ->
        expect(otherModel.validate).to.have.been.called

    context 'editing the name field', ->
      beforeEach ->
        sinon.spy model, 'validate'

      beforeEach setupEditableBefore
      afterEach setupEditableAfter

      context 'then pressing enter', ->
        it 'should persist the data', ->
          expect(view.$field()).to.contain 'Peter Bishop'
          expect(success).to.have.been.called
          expect(view.$field()).to.not.have.attr 'contenteditable'

        it 'should validate using the model', ->
          expect(model.validate).to.have.been.called

      context 'then pressing escape', ->
        before ->
          event = $.Event 'keydown', keyCode: 27

        after ->
          event = null

        it 'should revert the data', ->
          expect(view.$field()).to.contain 'Olivia Dunham'
          expect(success).not.to.have.been.called
          expect(view.$field()).to.not.have.attr 'contenteditable'
          expect(model.validationError).to.be.null

      context 'then causing blur', ->
        before ->
          event = $.Event 'blur'

        after ->
          event = null

        it 'should persist the data', ->
          expect(view.$field()).to.contain 'Peter Bishop'
          expect(success).to.have.been.called
          expect(view.$field()).to.not.have.attr 'contenteditable'

        it 'should not have an href', ->
          expect(view.$field()).not.to.have.attr 'href'

      context 'with a paste', ->
        before ->
          event = $.Event 'paste'
          event.originalEvent =
            clipboardData: {getData: -> 'sesame'}
            preventDefault: ->

        after ->
          event = null

        it 'should insert the copied text', ->
          expect(document.execCommand).to.have.been.calledWith(
            'insertHTML', no, 'sesame'
          )

      context 'with an invalid value', ->
        expectNotRevertData = ->
          expect(success).not.to.have.been.called
          expect(error).to.have.been.called
          expect(view.$field()).to.have.text ''
          expect(view.$field()).to.have.class 'error-input'
          expect(view.$field()).to.have.attr 'contenteditable', 'true'
          expect(view.$field()).to.have.attr 'data-toggle', 'tooltip'
          expect(view.$field()).to.have.attr 'data-original-title',
            'attribute is empty'
        before ->
          value = ''

        after ->
          value = null

        context 'then pressing enter', ->
          expectNoError = ->
            expect(view.$field()).to.not.have.class 'error-input'
            expect(view.$field()).to.not.have.attr 'contenteditable'
            expect(view.$field()).to.not.have.attr 'data-toggle'
            expect(view.$field()).to.not.have.attr 'data-original-title'
            expect(model.validationError).to.not.exist

          it 'should not revert the data', ->
            expectNotRevertData.call this

          context 'then fixing the error', ->
            beforeEach ->
              view.$field().text('Walter Bishop').trigger enter

            it 'should remove the error class and saves', ->
              expect(success).to.have.been.called
              expect(error).to.have.been.calledOnce
              expectNoError.call this

          context 'then canceling edit', ->
            beforeEach ->
              escape = $.Event 'keydown', keyCode: 27
              view.$field().trigger escape

            it 'should remove the error class and reverts', ->
              expect(view.$field()).to.contain 'Olivia Dunham'
              expect(success).to.not.have.been.called
              expectNoError.call this

        context 'then causing blur', ->
          before ->
            event = $.Event 'blur'

          after ->
            event = null

          it 'should revert the data', ->
            expectNotRevertData.call this

        context 'and a custom error class', ->
          before ->
            errorClass = 'my-error'

          after ->
            errorClass = undefined

          context 'then pressing enter', ->
            it 'should attache the custom class', ->
              expect(view.$field()).to.have.class 'my-error'

        context 'and multiple editable views', ->
          model2 = null
          view2 = null

          beforeEach ->
            model2 = new FakeModel name: 'Phillip Broyles'
            view2 = new FakeView model: model2
            view2.setupEditable '.edit-name', '.name-field'
            view2.$('.edit-name').click()
            # Non-DOM fragments don't propagate a blur event on click.
            view.$('.name-field').blur()

          afterEach ->
            view2 = null
            model2 = null

          # Focus from makeEditable click triggers another blur.
          it 'should keep the original and does not focus the second one', ->
            # Original is with updated value.
            expect(view.$field()).to.have.attr 'contenteditable'
            expect(view.$field()).to.have.class 'error-input'
            expect(view.$field()).to.have.text ''
            # Second view is being edited.
            expect(view2.$field()).to.have.attr 'contenteditable'
            expect(view2.$field()).to.not.have.class 'error-input'
            expect(view2.$field()).to.contain 'Phillip Broyles'

      describe 'with the same value', ->
        before ->
          value = 'Olivia Dunham'

        after ->
          value = null

        context 'then pressing enter', ->
          it 'should do nothing', ->
            expect(view.$field()).to.contain 'Olivia Dunham'
            expect(success).not.to.have.been.called
            expect(view.$field()).to.not.have.attr 'contenteditable'

      context 'with a numeric value', ->
        before ->
          value = '1001'

        after ->
          value = null

        context 'then pressing enter', ->
          it 'should convert it to a number', ->
            expect(view.$field()).to.contain '1001'
            expect(success).to.have.been.called
            args = success.lastCall.args[0]
            expect(args).to.have.property 'value', 1001

    context 'editing an email field', ->
      beforeEach ->
        view.setupEditable '.edit-email', '.email-field'
        view.$('.edit-email').click()
        view.$('.email-field').text 'olivia.dunham@effbeeeye.com'
        view.$('.email-field').trigger enter

      it 'should update the href', ->
        expect(view.$ '.email-field').to.have.attr('href')
          .and.to.equal 'mailto:olivia.dunham@effbeeeye.com'

    context 'editing a URL field', ->
      url = null

      beforeEach ->
        view.setupEditable '.edit-url', '.url-field'
        view.$('.edit-url').click()
        view.$('.url-field').text(url or 'http://olivia.com')
        view.$('.url-field').trigger enter

      it 'should update the href', ->
        expect(view.$ '.url-field').to.have.attr('href')
          .and.to.equal 'http://olivia.com'

      context 'without a protocol', ->
        before ->
          url = 'olivia.com'

        after ->
          url = null

        it 'should make the href protocol relative', ->
          expect(view.$ '.url-field').to.have.attr('href')
            .and.to.equal '//olivia.com'

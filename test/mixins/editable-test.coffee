define (require) ->
  Chaplin = require 'chaplin'
  FakeModel = require 'test/helpers/validate-model'
  FakeView = require 'test/helpers/editable-view'
  setupEditable = require 'test/helpers/setup-editable'

  describe 'Editable mixin', ->
    beforeEach ->
      sinon.stub document, 'execCommand'
      @model = new FakeModel
        name: 'Olivia Dunham'
        email: 'odunham@effbeeeye.com'
        url: 'http://dunham.com'
      @view = new FakeView {@model}
      @success = sinon.spy()
      @error = sinon.spy()
      @opts = _.extend {
        @success
        @error
        @errorClass
      }, @customOpts
      @view.setupEditable '.edit-name', '.name-field', @opts
      @enter = $.Event 'keydown', keyCode: 13

    afterEach ->
      delete @enter
      @view.dispose()
      @model.dispose()
      delete @model
      delete @view
      delete @opts
      document.execCommand.restore()

    it 'attaches a click handler', ->
      @view.$('.edit-name').click()
      expect(@view.$field()).to.have.attr 'contenteditable'
      expect(document.execCommand).to.have.been.called

    describe 'optional model defined', ->
      before ->
        @otherModel = new FakeModel {test:'test'}
        sinon.spy @otherModel, 'validate'
        @customOpts =
          model: @otherModel
      beforeEach setupEditable.before
      afterEach setupEditable.after

      after ->
        delete @customOpts
        @otherModel.dispose()
        delete @otherModel

      it 'makes editable', ->
        expect(@otherModel.validate).to.have.been.called

    describe 'editing the name field', ->
      beforeEach ->
        sinon.spy @model, 'validate'

      beforeEach setupEditable.before

      afterEach setupEditable.after

      describe 'then pressing enter', ->
        it 'persists the data', ->
          expect(@view.$field()).to.contain 'Peter Bishop'
          expect(@success).to.have.been.called
          expect(@view.$field()).to.not.have.attr 'contenteditable'

        it 'validates using the model', ->
          expect(@model.validate).to.have.been.called

      describe 'then pressing escape', ->
        before ->
          @event = $.Event 'keydown', keyCode: 27

        after ->
          delete @event

        it 'reverts the data', ->
          expect(@view.$field()).to.contain 'Olivia Dunham'
          expect(@success).not.to.have.been.called
          expect(@view.$field()).to.not.have.attr 'contenteditable'
          expect(@model.validationError).to.be.null

      describe 'then causing blur', ->
        before ->
          @event = $.Event 'blur'

        after ->
          delete @event

        it 'persists the data', ->
          expect(@view.$field()).to.contain 'Peter Bishop'
          expect(@success).to.have.been.called
          expect(@view.$field()).to.not.have.attr 'contenteditable'

        it 'does not have an href', ->
          expect(@view.$field()).not.to.have.attr 'href'

      describe 'with a paste', ->
        before ->
          @event = $.Event 'paste'
          @event.originalEvent = clipboardData: {getData: -> 'sesame'}

        after ->
          delete @event

        it 'inserts the copied text', ->
          expect(document.execCommand).to.have.been.calledWith(
            'insertHTML', no, 'sesame'
          )

      describe 'with an invalid value', ->
        expectRevertData = ->
          expect(@success).not.to.have.been.called
          expect(@error).to.have.been.called
          expect(@view.$field()).to.contain 'Olivia Dunham'
          expect(@view.$field()).to.have.class 'error-input'
          expect(@view.$field()).to.have.attr 'contenteditable'
        before ->
          @value = ''

        after ->
          delete @value

        describe 'then pressing enter', ->
          expectNoError = ->
            expect(@view.$field()).to.not.have.class 'error-input'
            expect(@view.$field()).to.not.have.attr 'contenteditable'
            expect(@model.validationError).to.not.exist

          it 'reverts the data', ->
            expectRevertData.call this

          describe 'then fixing the error', ->
            beforeEach ->
              @view.$field().text('Walter Bishop').trigger @enter

            it 'removes the error class and saves', ->
              expect(@success).to.have.been.called
              expect(@error).to.have.been.calledOnce
              expectNoError.call this

          describe 'then canceling edit', ->
            beforeEach ->
              escape = $.Event 'keydown', keyCode: 27
              @view.$field().trigger escape

            it 'removes the error class and reverts', ->
              expect(@view.$field()).to.contain 'Olivia Dunham'
              expect(@success).to.not.have.been.called
              expectNoError.call this

        describe 'then causing blur', ->
          before ->
            @event = $.Event 'blur'

          after ->
            delete @event

          it 'reverts the data', ->
            expectRevertData.call this

        describe 'and a custom error class', ->
          before ->
            @errorClass = 'my-error'

          after ->
            delete @errorClass

          describe 'then pressing enter', ->
            it 'attaches the custom class', ->
              expect(@view.$field()).to.have.class 'my-error'

        describe 'and multiple editable views', ->
          before ->
            # These objects will be created before @model and @view
            @model2 = new FakeModel name: 'Phillip Broyles'
            @view2 = new FakeView model: @model2
            @view2.setupEditable '.edit-name', '.name-field'

          after ->
            delete @view2
            delete @model2

          beforeEach ->
            @view2.$('.edit-name').click()
            # Non-DOM fragments don't propagate a blur event on click.
            @view.$('.name-field').blur()

          # Focus from makeEditable click triggers another blur.
          it 'restores the original and focuses the second one', ->
            # Original is untouched.
            expect(@view.$field()).not.to.have.attr 'contenteditable'
            expect(@view.$field()).not.to.have.class 'error-input'
            expect(@view.$field()).to.contain 'Olivia Dunham'
            # Second view is being edited.
            expect(@view2.$field()).to.have.attr 'contenteditable'
            expect(@view2.$field()).to.not.have.class 'error-input'
            expect(@view2.$field()).to.contain 'Phillip Broyles'

      describe 'with the same value', ->
        before ->
          @value = 'Olivia Dunham'

        after ->
          delete @value

        describe 'then pressing enter', ->
          it 'does nothing', ->
            expect(@view.$field()).to.contain 'Olivia Dunham'
            expect(@success).not.to.have.been.called
            expect(@view.$field()).to.not.have.attr 'contenteditable'

      describe 'with a numeric value', ->
        before ->
          @value = '1001'

        after ->
          delete @value

        describe 'then pressing enter', ->
          it 'converts it to a number', ->
            expect(@view.$field()).to.contain '1001'
            expect(@success).to.have.been.called
            args = @success.lastCall.args[0]
            expect(args).to.have.property 'value', 1001

    describe 'editing an email field', ->
      beforeEach ->
        @view.setupEditable '.edit-email', '.email-field'
        @view.$('.edit-email').click()
        @view.$('.email-field').text 'olivia.dunham@effbeeeye.com'
        @view.$('.email-field').trigger @enter

      it 'updates the href', ->
        expect(@view.$ '.email-field').to.have.attr('href')
          .and.to.equal 'mailto:olivia.dunham@effbeeeye.com'

    describe 'editing a URL field', ->
      beforeEach ->
        @view.setupEditable '.edit-url', '.url-field'
        @view.$('.edit-url').click()
        @view.$('.url-field').text(@url or 'http://olivia.com')
        @view.$('.url-field').trigger @enter

      it 'updates the href', ->
        expect(@view.$ '.url-field').to.have.attr('href')
          .and.to.equal 'http://olivia.com'

      describe 'without a protocol', ->
        before ->
          @url = 'olivia.com'

        after ->
          delete @url

        it 'makes the href protocol relative', ->
          expect(@view.$ '.url-field').to.have.attr('href')
            .and.to.equal '//olivia.com'

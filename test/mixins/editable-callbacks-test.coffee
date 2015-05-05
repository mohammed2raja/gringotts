define (require) ->
  Chaplin = require 'chaplin'
  editable = require 'mixins/editable'
  FakeModel = require 'test/helpers/validate-model'
  FakeView = require 'test/helpers/editable-view'
  setupEditable = require 'test/helpers/setup-editable'

  describe 'Editable callbacks', ->
    beforeEach ->
      sinon.stub document, 'execCommand'
      @model = new FakeModel
        name: 'Olivia Dunham'
        email: 'odunham@effbeeeye.com'
        url: 'http://dunham.com'
      @view = new FakeView {@model}
      @view.errorCallback = sinon.spy()
      @view.cleanCallback = sinon.spy()
      @view.setupEditable '.edit-name', '.name-field', {
        @patch
        saveMessage: 'Model updated'
        success: @view.delayedSave
        error: (error, opts) ->
          @errorCallback error, opts
        clean: (opts) ->
          @cleanCallback opts
      }
      @view.setupEditable '.edit-email', '.email-field',
        saveMessage: 'Model updated'
        success: @view.delayedSave
      @enter = $.Event 'keydown', keyCode: 13

    afterEach ->
      delete @enter
      @view.dispose()
      @model.dispose()
      document.execCommand.restore()

    describe 'editing a field', ->
      beforeEach ->
        sinon.spy @view, 'publishEvent'
        sinon.spy @model, 'save'
        # prevent save from trying to hit a server
        sinon.stub @model, 'sync'

      beforeEach setupEditable.before

      afterEach setupEditable.after

      describe 'then pressing enter', ->
        it 'calls success and publishes a notification', ->
          expect(@view.publishEvent).to.have.been.calledWith 'notify'

        describe 'success callback', ->
          beforeEach ->
            @view.publishEvent.lastCall.args[2].success()

          it 'saves the model', ->
            expect(@model.save).to.have.been.calledWith 'name', @value

          it 'sets the value on model', ->
            expect(@model.get 'name').to.equal @value

          describe 'with patch', ->
            before ->
              @patch = yes

            after ->
              delete @patch

            it 'uses patch to save', ->
              opts = @model.save.lastCall.args[2]
              expect(opts).to.have.property 'patch', yes

          describe 'with a second editable', ->
            beforeEach ->
              @view.$('.edit-email').click()
              @view.$('.email-field').text 'peter@bishop.com'
              @view.$('.email-field').trigger @enter

            it 'can edit both', ->
              expect(@view.publishEvent).to.have.been.calledTwice
              expect(@view.$ '.name-field').to.contain 'Peter Bishop'
              expect(@view.$ '.email-field').to.contain 'peter@bishop.com'

            describe 'after success', ->
              beforeEach ->
                @view.publishEvent.lastCall.args[2].success()

              it 'has saved both times', ->
                expect(@model.save).to.have.been.calledTwice

            describe 'after undo', ->
              beforeEach ->
                @view.publishEvent.lastCall.args[2].undo()

              it 'reverts the last change', ->
                email = 'odunham@effbeeeye.com'
                expect(@view.$ '.email-field').to.contain email

              it 'leaves the first change', ->
                expect(@view.$ '.name-field').to.contain 'Peter Bishop'

        describe 'undo callback', ->
          beforeEach ->
            @view.publishEvent.lastCall.args[2].undo()

          it 'reverts the text', ->
            expect(@view.$(@field)).to.contain 'Olivia Dunham'

          describe 'on a link', ->
            before ->
              @click = '.edit-email'
              @field = '.email-field'
              @value = 'peter@bishop.org'

            after ->
              delete @value
              delete @field
              delete @click

            it 'reverts the href', ->
              expect(@view.$ '.email-field').to.have.attr('href')
                .and.to.equal 'mailto:odunham@effbeeeye.com'

          it 'becomes editable again', ->
            expect(@view.$(@field)).to.have.attr 'contenteditable'

        describe 'with an invalid value', ->
          before ->
            @value = ''

          after ->
            delete @value

          it 'calls the error callback', ->
            expect(@view.errorCallback).to.have.been.called

        describe 'without changing the value', ->
          before ->
            @value = 'Olivia Dunham'

          after ->
            delete @value

          it 'calls the clean callback', ->
            expect(@view.cleanCallback).to.have.been.called

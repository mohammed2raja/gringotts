define (require) ->
  Chaplin = require 'chaplin'
  FakeModel = require 'test/helpers/validate-model'
  FakeView = require 'test/helpers/editable-view'

  describe 'Editable callbacks', ->
    server = null
    model = null
    view = null
    patch = null
    enter = null
    field = null
    click = null
    value = null
    event = null

    # TODO: this is a duplicate from editable-test
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
      server = sinon.fakeServer.create()
      sinon.stub document, 'execCommand'
      model = new FakeModel
        name: 'Olivia Dunham'
        email: 'odunham@effbeeeye.com'
        url: 'http://dunham.com'
      view = new FakeView {model}
      view.errorCallback = sinon.spy()
      view.cleanCallback = sinon.spy()
      view.setupEditable '.edit-name', '.name-field', {
        patch
        saveMessage: 'Model updated'
        success: view.genericSave
        delayedSave: true
        error: (error, opts) ->
          @errorCallback error, opts
        clean: (opts) ->
          @cleanCallback opts
      }
      view.setupEditable '.edit-email', '.email-field',
        saveMessage: 'Model updated'
        success: view.genericSave
        delayedSave: true
      enter = $.Event 'keydown', keyCode: 13

    afterEach ->
      server.restore()
      document.execCommand.restore()
      enter = null
      view.dispose()
      model.dispose()
      model = null
      view = null

    describe 'editing a field', ->
      beforeEach ->
        sinon.spy view, 'publishEvent'
        sinon.spy model, 'save'

      beforeEach setupEditableBefore
      afterEach setupEditableAfter

      describe 'then pressing enter', ->
        it 'calls success and publishes a notification', ->
          expect(view.publishEvent).to.have.been.calledWith 'notify'

        describe 'success callback', ->
          beforeEach ->
            view.publishEvent.lastCall.args[2].success()
            server.respondWith JSON.stringify domain_name: 'Peter Bishop'
            server.respond()

          it 'saves the model', ->
            expect(model.save).to.have.been.calledWith 'name', value

          it 'sets the value on model', ->
            expect(model.get 'name').to.equal value

          describe 'with patch', ->
            before ->
              patch = yes

            after ->
              patch = null

            it 'uses patch to save', ->
              opts = model.save.lastCall.args[2]
              expect(opts).to.have.property 'patch', yes

          describe 'with a second editable', ->
            beforeEach ->
              view.$('.edit-email').click()
              view.$('.email-field').text 'peter@bishop.com'
              view.$('.email-field').trigger enter

            it 'can edit both', ->
              expect(view.publishEvent).to.have.been.calledTwice
              expect(view.$ '.name-field').to.contain 'Peter Bishop'
              expect(view.$ '.email-field').to.contain 'peter@bishop.com'

            describe 'after success', ->
              beforeEach ->
                view.publishEvent.lastCall.args[2].success()
                server.respond()

              it 'has saved both times', ->
                expect(model.save).to.have.been.calledTwice

            describe 'after undo', ->
              beforeEach ->
                view.publishEvent.lastCall.args[2].undo()

              it 'reverts the last change', ->
                email = 'odunham@effbeeeye.com'
                expect(view.$ '.email-field').to.contain email

              it 'leaves the first change', ->
                expect(view.$ '.name-field').to.contain 'Peter Bishop'

        describe 'undo callback', ->
          beforeEach ->
            view.publishEvent.lastCall.args[2].undo()

          it 'reverts the text', ->
            expect(view.$(field)).to.contain 'Olivia Dunham'

          describe 'on a link', ->
            before ->
              click = '.edit-email'
              field = '.email-field'
              value = 'peter@bishop.org'

            after ->
              value = null
              field = null
              click = null

            it 'reverts the href', ->
              expect(view.$ '.email-field').to.have.attr('href')
                .and.to.equal 'mailto:odunham@effbeeeye.com'

          it 'becomes editable again', ->
            expect(view.$(field)).to.have.attr 'contenteditable'

        describe 'with an invalid value', ->
          before ->
            value = ''

          after ->
            value = null

          it 'calls the error callback', ->
            expect(view.errorCallback).to.have.been.called

        describe 'without changing the value', ->
          before ->
            value = 'Olivia Dunham'

          after ->
            value = null

          it 'calls the clean callback', ->
            expect(view.cleanCallback).to.have.been.called

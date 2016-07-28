define (require) ->
  Chaplin = require 'chaplin'
  GenericSave = require 'mixins/views/generic-save'

  class MockView extends GenericSave Chaplin.View

  describe 'GenericSave', ->
    view = null
    model = null
    opts = null
    customOpts = null
    saveDeferred = null

    beforeEach (done) ->
      view = new MockView()
      sinon.stub view, 'publishEvent'
      model = new Chaplin.Model()
      saveDeferred = $.Deferred()
      sinon.stub model, 'save', -> saveDeferred
      opts = _.extend {}, customOpts, {
        model
        saveMessage: 'Model saved'
        attribute: 'name'
        value: 'John'
        original: 'Eugene'
        href: 'inbox@gmail.com'
        $field:
          text: sinon.spy()
          attr: sinon.spy()
      }
      view.genericSave opts
      done()

    afterEach ->
      model.save.restore()
      model.dispose()
      view.publishEvent.restore()
      view.dispose()

    expectRevertChanges = ->
      expect(opts.$field.text).to.have.been.calledWith opts.original
      expect(opts.$field.attr).to.have.been.calledWith 'href', opts.href

    it 'should call save', ->
      expect(model.save).to.have.been
        .calledWith opts.attribute, opts.value

    context 'with custom options', ->
      before -> customOpts = patch: yes
      after -> customOpts = null

      it 'should call save with options', ->
        expect(model.save).to.have.been.calledWith opts.attribute,
          opts.value, sinon.match.has 'patch', yes

    context 'with sent validation on', ->
      before -> customOpts = validate: yes
      after -> customOpts = null

      it 'should not send notification', ->
        expect(view.publishEvent).to.have.not.been.called

      it 'should call save without validation', ->
        expect(model.save).to.have.been.calledWith opts.attribute,
          opts.value, sinon.match.has 'validate', no

    context 'on save success', ->
      beforeEach ->
        saveDeferred.resolve()

      it 'should send notification', ->
        expect(view.publishEvent).to.have.been
          .calledWith 'notify', opts.saveMessage

    context 'on save error', ->
      xhr = null
      status = undefined
      responseText = undefined

      beforeEach ->
        xhr = {status, responseText}
        saveDeferred.reject xhr
        return {} # avoid passing error promise to mocha

      it 'should revert changes', ->
        expectRevertChanges()

      it 'should not handle error', ->
        expect(xhr.errorHandled).to.be.undefined

      context 'with a correct validation info', ->
        before ->
          status = 406
          responseText = JSON.stringify errors: name: 'Invalid Value'
        after ->
          status = undefined
          responseText = undefined

        it 'should send error notification', ->
          expect(view.publishEvent).to.have.been.calledWith 'notify',
            'Invalid Value', sinon.match.has 'classes', 'alert-danger'

        it 'should handle error', ->
          expect(xhr.errorHandled).to.be.true

      context 'with an incomplete validation info', ->
        before ->
          status = 406
          responseText = ''
        after ->
          status = undefined
          responseText = undefined

        it 'should not handle error', ->
          expect(xhr.errorHandled).to.be.undefined

    context 'with delayed save', ->
      before -> customOpts = delayedSave: yes
      after -> customOpts = null

      it 'should not call save', ->
        expect(model.save).to.have.not.been.called

      it 'should send notification', ->
        expect(view.publishEvent).to.have.been.calledWith 'notify',
          opts.saveMessage, sinon.match.has 'model', opts.model

      context 'on notification success', ->
        beforeEach (done) ->
          callOpts = view.publishEvent.getCall(0).args[2]
          callOpts.success()
          done()

        it 'should call save', ->
          expect(model.save).to.have.been
            .calledWith opts.attribute, opts.value

        context 'on save error', ->
          beforeEach ->
            saveDeferred.reject()
            return {} # avoid passing error promise to mocha

          it 'should revert changes', ->
            expectRevertChanges()

        context 'with custom options and validation', ->
          before ->
            customOpts.patch = yes
            customOpts.validate = yes
          after ->
            customOpts.patch = null
            customOpts.validate = null

          it 'should call save with options', ->
            expect(model.save).to.have.been.calledWith opts.attribute,
              opts.value, sinon.match.has 'patch', yes
            expect(model.save).to.have.been.calledWith opts.attribute,
              opts.value, sinon.match.has 'validate', no

      context 'on notification undo', ->
        beforeEach ->
          callOpts = view.publishEvent.getCall(0).args[2]
          callOpts.undo()

        it 'should revert changes', ->
          expectRevertChanges()

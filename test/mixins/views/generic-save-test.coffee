define (require) ->
  Chaplin = require 'chaplin'
  GenericSave = require 'mixins/views/generic-save'

  class ViewMock extends GenericSave Chaplin.View

  describe 'GenericSave', ->
    sandbox = null
    view = null
    model = null
    response = null
    opts = null
    customOpts = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      sandbox.server.respondWith response or '{}'
      sandbox.server.autoRespond = yes
      view = new ViewMock()
      sandbox.stub view, 'publishEvent'
      sandbox.stub view, 'handleError'
      model = new Chaplin.Model()
      model.url = '/foo'
      sandbox.spy model, 'save'
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

    afterEach ->
      sandbox.restore()
      model.dispose()
      view.dispose()

    expectRevertChanges = ->
      expect(opts.$field.text).to.have.been.calledWith opts.original
      expect(opts.$field.attr).to.have.been.calledWith 'href', opts.href

    it 'should call save', ->
      expect(model.save).to.have.been
        .calledWith opts.attribute, opts.value

    context 'with custom options', ->
      before ->
        customOpts = patch: yes

      after ->
        customOpts = null

      it 'should call save with options', ->
        expect(model.save).to.have.been.calledWith opts.attribute,
          opts.value, sinon.match.has 'patch', yes

    context 'with sent validation on', ->
      before ->
        customOpts = validate: yes

      after ->
        customOpts = null

      it 'should call save without validation', ->
        expect(model.save).to.have.been.calledWith opts.attribute,
          opts.value, sinon.match.has 'validate', no

    it 'should send notification', ->
      expect(view.publishEvent).to.have.been
        .calledWith 'notify', opts.saveMessage

    context 'on save error', ->
      context 'with a correct validation info', ->
        before ->
          response = [406, {}, JSON.stringify errors: name: 'Invalid Value']

        after ->
          response = null

        it 'should revert changes', ->
          expectRevertChanges()

        it 'should send error notification', ->
          expect(view.publishEvent).to.have.been.calledWith 'notify',
            'Invalid Value', sinon.match.has 'classes', 'alert-danger'

        it 'should not handle error', ->
          expect(view.handleError).to.not.have.been.calledOnce

      context 'with an incomplete validation info', ->
        before ->
          response = [406, {}, '']

        after ->
          response = null

        it 'should revert changes', ->
          expectRevertChanges()

        it 'should not send error notification', ->
          expect(view.publishEvent).to.have.not.been.calledOnce

        it 'should handle error', ->
          expect(view.handleError).to.have.been.calledOnce

    context 'with delayed save', ->
      before ->
        customOpts = delayedSave: yes

      after ->
        customOpts = null

      it 'should not call save', ->
        expect(model.save).to.have.not.been.called

      it 'should send notification', ->
        expect(view.publishEvent).to.have.been.calledWith 'notify',
          opts.saveMessage, sinon.match.has 'model', opts.model

      context 'on notification success', ->
        beforeEach ->
          callOpts = view.publishEvent.getCall(0).args[2]
          callOpts.success()

        it 'should call save', ->
          expect(model.save).to.have.been
            .calledWith opts.attribute, opts.value

        context 'on save error', ->
          before ->
            response = [500, {}, '']

          after ->
            response = null

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

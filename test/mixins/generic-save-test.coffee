define (require) ->
  Chaplin = require 'chaplin'
  genericSave = require 'mixins/generic-save'

  describe 'Generic save mixin', ->
    view = null
    model = null
    opts = null
    customOpts = null

    beforeEach ->
      view = new Chaplin.View()
      sinon.stub view, 'publishEvent'
      model = new Chaplin.Model()
      sinon.stub model, 'save'
      genericSave.call view
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
        callOpts = model.save.getCall(0).args[2]
        callOpts.success()

      it 'should send notification', ->
        expect(view.publishEvent).to.have.been
          .calledWith 'notify', opts.saveMessage

    context 'on save error', ->
      beforeEach ->
        callOpts = model.save.getCall(0).args[2]
        callOpts.error()

      it 'should revert changes', ->
        expectRevertChanges.call this

    context 'with delayed save', ->
      before -> customOpts = delayedSave: yes
      after -> customOpts = null

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
          beforeEach ->
            callOpts = model.save.getCall(0).args[2]
            callOpts.error()

          it 'should revert changes', ->
            expectRevertChanges.call this

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
          expectRevertChanges.call this

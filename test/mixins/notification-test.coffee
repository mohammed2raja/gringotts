define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  notification = require 'mixins/notification'

  describe 'Notification mixin', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      @success = sinon.spy()
      @undo = sinon.spy()
      opts = {@success, @undo, model: new Chaplin.Model()}
      @model = new Chaplin.Model {opts}
      @view = new Chaplin.View {@model}
      @view.getTemplateFunction = ->
        -> '<button type="button" class="close">&times;</button>'
      advice.call @view
      notification.call @view
      sinon.spy @view, 'dismiss'
      @view.render()

    afterEach ->
      @view.dispose()
      @model.dispose()
      @clock.restore()

    it 'dismisses itself after a few seconds', ->
      @clock.tick 4500
      expect(@view.dismiss).to.have.been.called
      expect(@success).to.have.been.called

    it 'can be manually dismissed', ->
      @view.$('.close').click()
      expect(@view.dismiss).to.have.been.called

    it 'only shows an undo link conditionally', ->
      @model.set 'opts', {}
      @view.render()
      expect(@view.$ '.undo').not.to.exist

    it 'can add an undo element', ->
      expect(@view.$ '.undo').to.exist

    it 'displays only one undo at a time', ->
      sinon.spy $.fn, 'remove'
      sinon.spy @view, 'getUndoElement'
      @view.render()
      expect($.fn.remove).to.be.calledOnce
      expect(@view.getUndoElement).to.be.calledOnce
      $.fn.remove.restore()

    it 'invokes callback before device is disposed', ->
      @model.get('opts').model.trigger 'dispose'
      expect(@success).to.have.been.called

    it 'can dispose on navigation', ->
      @model.set 'opts', navigateDismiss: yes
      # Kick off logic during construction.
      @view.initialize()
      @view.publishEvent 'dispatcher:dispatch'
      expect(@view.dismiss).to.be.calledOnce

    it 'only disposes errors on navigation if navigateDismiss', ->
      sinon.spy @model, 'dispose'
      @model.unset 'opts'
      # Kick off logic during construction.
      @view.initialize()
      @view.publishEvent 'dispatcher:dispatch'
      expect(@model.dispose).not.to.be.called

    it 'does not call the timeout with the sticky option', ->
      sinon.stub window, 'setTimeout'
      @model.set 'opts', sticky: yes
      @model.timeout = null
      @view.render()
      expect(window.setTimeout).not.to.be.called
      expect(@model.timeout).not.to.exist

    it 'allows the timeout to be changed', ->
      notification.call @view, reqTimeout: 888
      @view.render()
      @clock.tick 888
      expect(@success).to.have.been.called
      expect(@model.timeout).to.exist

    it 'allows instances to change the timeout', ->
      @model.set 'opts', reqTimeout: 101
      @view.render()
      @clock.tick 101
      expect(@view.dismiss).to.have.been.calledOnce

    it 'allows the undo selector to be changed', ->
      notification.call @view, undoSelector: '#undo'
      @view.render()
      @view.$el.append '<a id="undo">'
      @view.$('#undo').click()
      expect(@undo).to.have.been.called

    it 'adds specified classes', ->
      @model.set 'opts', classes: 'none'
      @view.attach()
      expect(@view.$el).to.have.class 'none'

    it 'adds default class', ->
      @view.attach()
      expect(@view.$el).to.have.class 'alert-success'

    describe 'on undo', ->
      beforeEach ->
        expect(@view.$ '.undo').to.exist
        @view.$('.undo').click()

      it 'it dismisses', ->
        expect(@view.dismiss).to.have.been.called
        expect(@undo).to.have.been.called

      it 'does not call the success method', ->
        @clock.tick 4500
        expect(@success).not.to.be.called

    describe 'on dismiss', ->
      beforeEach ->
        sinon.spy $.fn, 'animate'
        notification.call @view, fadeSpeed: 0
      afterEach ->
        $.fn.animate.restore()

      it 'disposes the model', ->
        @view.dismiss()
        expect(@model.disposed).to.be.true
        expect($.fn.animate).to.have.been.calledOnce

      it 'does not dispose the model if it is already disposed', ->
        sinon.spy @model, 'dispose'
        @model.dispose()
        @view.dismiss()
        expect(@model.dispose).to.be.calledOnce

      it 'does not animate without an element', ->
        $el = @view.$el
        @view.$el = null
        @view.dismiss()
        expect($.fn.animate).not.to.have.been.called
        @view.$el = $el

    describe 'with a deferred (like an AJAX request)', ->
      beforeEach ->
        @model.set 'opts', deferred: new $.Deferred()
        @view.render()

      it 'dismisses when it succeeds', ->
        @model.get('opts').deferred.resolve()
        expect(@view.dismiss).to.have.been.called

    describe 'with an arbitrary click handler', ->
      beforeEach ->
        @handler = sinon.spy()
        @model.set 'opts', click: {selector: '.arbitrary', @handler}
        @view.getTemplateFunction = ->
          -> 'Some text <a href="#" class="arbitrary">A link</a>'
        @view.render()

      it 'executes the handler', ->
        @view.$('.arbitrary').click()
        expect(@handler).to.have.been.called

    it 'can append arbitrary links', ->
      @model.set 'opts', link: '<a href="#" class="arbitrary">A link</a>'
      @view.render()
      expect(@view.$ '.arbitrary').to.exist

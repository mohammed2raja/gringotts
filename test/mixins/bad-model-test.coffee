define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  advice = require 'mixins/advice'
  badModel = require 'mixins/bad-model'

  describe 'Bad model mixin', ->
    setupListeners = ->
      @view.delegateListeners()
      @model.trigger 'error', @model, status: 404

    beforeEach ->
      @model = new Chaplin.Model {id: 56}
      @view = new Chaplin.View {@model}
      advice.call @view
      sinon.stub utils, 'redirectTo'
      sinon.stub @view, 'publishEvent'

    afterEach ->
      utils.redirectTo.restore()
      @view.dispose()
      @model.dispose()

    context 'informs user of error', ->
      beforeEach ->
        badModel.call @view
        @view.delegateListeners()

      defaultExpects = ->
        expect(utils.redirectTo.lastCall).to.be.calledWith ''
        expect(@view.publishEvent.lastCall).to.be.calledWith 'notify'
        # Default message contains model ID.
        expect(@view.publishEvent.lastCall.args[1]).to.be.contain @model.id

      context 'for 400s', ->
        beforeEach ->
          @xhr = status: 400
          @model.trigger 'error', @model, @xhr
        afterEach ->
          delete @xhr

        it 'should redirect and publish event', ->
          defaultExpects.call this

        it 'should mark xhr as errorHandled', ->
          expect(@xhr).to.have.property('errorHandled').
            and.equal true

      context 'for 403s', ->
        beforeEach ->
          @xhr = status: 403
          @model.trigger 'error', @model, @xhr
        afterEach ->
          delete @xhr

        it 'should redirect and publish event', ->
          defaultExpects.call this

        it 'should mark xhr as errorHandled', ->
          expect(@xhr).to.have.property('errorHandled').
            and.equal true

      context 'for 404s', ->
        beforeEach ->
          @xhr = status: 404
          @model.trigger 'error', @model, @xhr
        afterEach ->
          delete @xhr

        it 'should redirect and publish event', ->
          defaultExpects.call this

        it 'should mark xhr as errorHandled', ->
          expect(@xhr).to.have.property('errorHandled').
            and.equal true

    it 'should redirect to the specified route', ->
      badModel.call @view, route: '66'
      setupListeners.call this
      expect(utils.redirectTo).to.be.calledWith '66'

    it 'should display specified message', ->
      badModel.call @view, message: 'oops'
      setupListeners.call this
      expect(@view.publishEvent.lastCall.args[1]).to.be.equal 'oops'

    it 'should invoke message as a method if appropriate', ->
      message = sinon.spy()
      badModel.call @view, {message}
      setupListeners.call this
      expect(message).to.be.calledWith @model

    it 'should invoke route as a method if appropriate', ->
      route = sinon.spy()
      badModel.call @view, {route}
      setupListeners.call this
      expect(route).to.be.calledWith @model

    it 'should pass route result to redirect call', ->
      badModel.call @view, route: -> ['name', id: 1]
      setupListeners.call this
      args = utils.redirectTo.lastCall.args
      expect(args[0]).to.equal 'name'
      expect(args[1]).to.eql id: 1

    it 'should allow notify options to be passed in', ->
      badModel.call @view, evtOpts: {'hey'}
      setupListeners.call this
      expect(@view.publishEvent.lastCall.args[2].hey).to.equal 'hey'

    it 'should use default options for notify', ->
      badModel.call @view
      # Invoke manually since it normally would be mixed in at declaration.
      setupListeners.call this
      defaults = @view.publishEvent.lastCall.args[2]
      expect(defaults.classes).to.exist
      expect(defaults.reqTimeout).to.exist

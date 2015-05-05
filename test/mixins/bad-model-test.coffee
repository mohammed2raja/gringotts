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

    describe 'informs user of error', ->
      beforeEach ->
        badModel.call @view
        # Invoke manually since it normally would be mixed in at declaration.
        setupListeners.call this
      afterEach ->
        expect(utils.redirectTo.lastCall).to.be.calledWith ''
        expect(@view.publishEvent.lastCall).to.be.calledWith 'notify'
        # Default message contains model ID.
        expect(@view.publishEvent.lastCall.args[1]).to.be.contain @model.id

      it 'for 403s', ->
        @model.trigger 'error', @model, status: 403

      it 'for 404s', ->
        setupListeners.call this

    it 'redirects to the specified route', ->
      badModel.call @view, route: '66'
      setupListeners.call this
      expect(utils.redirectTo).to.be.calledWith '66'

    it 'displays specified message', ->
      badModel.call @view, message: 'oops'
      setupListeners.call this
      expect(@view.publishEvent.lastCall.args[1]).to.be.equal 'oops'

    it 'invokes message as a method if appropriate', ->
      message = sinon.spy()
      badModel.call @view, {message}
      setupListeners.call this
      expect(message).to.be.calledWith @model

    it 'allows notify options to be passed in', ->
      badModel.call @view, evtOpts: {'hey'}
      setupListeners.call this
      expect(@view.publishEvent.lastCall.args[2].hey).to.equal 'hey'

    it 'uses default options for notify', ->
      badModel.call @view
      # Invoke manually since it normally would be mixed in at declaration.
      setupListeners.call this
      defaults = @view.publishEvent.lastCall.args[2]
      expect(defaults.classes).to.exist
      expect(defaults.reqTimeout).to.exist

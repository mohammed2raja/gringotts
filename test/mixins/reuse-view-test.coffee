define (require) ->
  Chaplin = require 'chaplin'
  reuseMixin = require 'mixins/reuse-view'

  stubCollection = ->
    col = new Chaplin.Collection()
    sinon.stub col, 'fetch'
    sinon.stub col, 'reset'
    col

  describe 'Reuse view mixin', ->
    models = null
    view = null
    collection = null
    controller = null

    beforeEach ->
      models = sinon.spy()
      view = sinon.spy()
      collection = stubCollection()
      controller = new Chaplin.Controller()
      controller.title = 'admiral'

      reuseMixin.call controller
      sinon.stub(controller, 'reuse').returns collection
      controller.reuseView {query: 'omelette'}, models, view

    afterEach ->
      controller.dispose()
      collection.dispose()

    it 'defaults to pre-defined name', ->
      expect(controller.reuse).to.be.calledWith 'admiral-view'

    it 'uses specified name', ->
      controller.viewName = 'lazorgator'
      controller.reuseView()
      expect(controller.reuse).to.be.calledWith 'lazorgator'

    it 'properly resets the collection', ->
      expect(collection.reset).to.be.calledOnce
      expect(collection.fetch).to.be.calledWith {query: 'omelette'}

    it 'allows constructor options to be passed in', ->
      opts = {'brian'}
      params = {opts}
      controller.reuseView params
      expect(controller.reuse.lastCall.args[2].brian).to.equal 'brian'

define (require) ->
  Chaplin = require 'chaplin'
  CollectionView = require 'views/base/collection-view'

  class ItemViewMock extends Chaplin.View
    className: 'test-item'
    getTemplateFunction: -> -> '<span>'

  class CollectionViewMock extends CollectionView
    itemView: ItemViewMock

  describe 'CollectionView', ->
    collection = null
    view = null
    models = null

    beforeEach ->
      models = [
        new Chaplin.Model()
        new Chaplin.Model()
        new Chaplin.Model()
      ]
      collection = new Chaplin.Collection models
      view = new CollectionViewMock {collection}

    afterEach ->
      collection.dispose()
      view.dispose()

    it 'should be initialized', ->
      expect(view).to.be.an.instanceOf CollectionView

    context 'modelsFrom helper', ->
      it 'should return models by rows', ->
        expect(view.modelsFrom view.$ '.test-item').to.eql models

      it 'should return model by a row', ->
        expect(view.modelsFrom view.$('.test-item')[0]).to.eql [models[0]]

    context 'rowsFrom helper', ->
      it 'should return rows by models', ->
        expect(view.rowsFrom models).to.eql view.$('.test-item').toArray()

      it 'should return row by a model', ->
        expect(view.rowsFrom models[0]).to.eql [view.$('.test-item')[0]]

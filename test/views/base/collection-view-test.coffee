define (require) ->
  Chaplin = require 'chaplin'
  CollectionView = require 'views/base/collection-view'

  class MockItemView extends Chaplin.View
    className: 'test-item'
    getTemplateFunction: -> -> '<span>'

  class MockCollectionView extends CollectionView
    itemView: MockItemView

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
      view = new MockCollectionView {collection}

    afterEach ->
      collection.dispose()
      view.dispose()

    it 'should be initialized', ->
      expect(view).to.be.an.instanceOf CollectionView

    context 'modelsBy helper', ->
      it 'should return models by rows', ->
        expect(view.modelsBy view.$ '.test-item').to.eql models

    context 'rowsBy helper', ->
      it 'should return rows by models', ->
        expect(view.rowsBy models).to.eql view.$('.test-item').toArray()

define (require) ->
  Chaplin = require 'chaplin'
  CollectionView = require 'views/base/collection-view'

  describe 'CollectionView', ->
    collection = null
    view = null

    beforeEach ->
      collection = new Chaplin.Collection()
      view = new CollectionView {collection}

    afterEach ->
      collection.dispose()
      view.dispose()

    it 'should be initialized', ->
      expect(view).to.be.an.instanceOf CollectionView

define (require) ->
  Chaplin = require 'chaplin'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  ServiceErrorReady = require 'mixins/views/service-error-ready'

  class MockCollectionView extends ServiceErrorReady Chaplin.CollectionView
    getTemplateFunction: ->
      -> '''
        <div class="service-error" style="display: none;"></div>
        <div class="error" style="display: none;"></div>
      '''

  class MockCollection extends ActiveSyncMachine Chaplin.Collection

  describe 'ServiceErrorReady', ->
    view = null
    collection = null

    serviceAssertions = (selector = '.service-error') ->
      context 'when collection is unsynced due to error', ->
        beforeEach ->
          collection.trigger 'unsynced'

        it 'should shows the error element', ->
          expect(view.$ selector).not.to.have.css 'display', 'none'

      context 'when collection started to sync', ->
        beforeEach ->
          collection.trigger 'syncing'

        it 'should hide the error element', ->
          expect(view.$ selector).to.have.css 'display', 'none'

      context 'when collection was synced', ->
        beforeEach ->
          collection.trigger 'synced'

        it 'should hide the error element', ->
          expect(view.$ selector).to.have.css 'display', 'none'

    beforeEach ->
      collection = new MockCollection()
      view = new MockCollectionView {collection}

    afterEach ->
      view.dispose()
      collection.dispose()

    serviceAssertions()

    context 'with error selector', ->
      before ->
        MockCollectionView::errorSelector = '.error'

      after ->
        delete MockCollectionView::errorSelector

      serviceAssertions '.error'

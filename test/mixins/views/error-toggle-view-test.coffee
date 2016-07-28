define (require) ->
  Chaplin = require 'chaplin'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  ServiceErrorReady = require 'mixins/views/service-error-ready'

  class ItemViewTest extends Chaplin.View
    autoRender: yes
    getTemplateFunction: ->
      -> '<span>1</span>'

  class CollectionViewTest extends ServiceErrorReady Chaplin.CollectionView
    autoRender: yes
    itemView: ItemViewTest
    getTemplateFunction: ->
      -> '''
        <div class="service-error" style="display: none;"></div>
        <div class="error" style="display: none;"></div>
      '''

  class ActiveSyncCollection extends ActiveSyncMachine Chaplin.Collection

  describe 'ServiceErrorReady', ->
    view = null
    collection = null
    syncMachine = null

    serviceAssertions = (selector = '.service-error') ->
      describe 'when service is unavailable', ->
        beforeEach ->
          collection.trigger 'service-unavailable'

        it 'shows the error element', ->
          expect(view.$ selector).not.to.have.css 'display', 'none'

      describe 'when the sync state changes', ->
        before ->
          syncMachine = yes
        beforeEach ->
          collection.trigger 'syncStateChange'

        after ->
          syncMachine = null

        it 'hides the error element', ->
          expect(view.$ selector).to.have.css 'display', 'none'

    beforeEach ->
      if syncMachine
        collection = new ActiveSyncCollection {}
      else
        collection = new Chaplin.Collection {}
      view = new CollectionViewTest {collection}

    afterEach ->
      view.dispose()
      collection.dispose()

    serviceAssertions()

    describe 'with error selector', ->
      before ->
        CollectionViewTest::errorSelector = '.error'
      after ->
        delete CollectionViewTest::errorSelector

      serviceAssertions '.error'

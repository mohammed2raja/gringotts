define (require) ->
  Chaplin = require 'chaplin'
  advice = require 'mixins/advice'
  activeSyncMachine = require 'mixins/active-sync-machine'
  errorToggleView = require 'mixins/error-toggle-view'

  class ItemViewTest extends Chaplin.View
    autoRender: yes
    getTemplateFunction: ->
      -> '<span>1</span>'

  class CollectionViewTest extends Chaplin.CollectionView
    advice.call @prototype
    errorToggleView.call @prototype
    autoRender: yes
    itemView: ItemViewTest
    getTemplateFunction: ->
      -> '''
        <div class="service-error" style="display: none;"></div>
        <div class="error" style="display: none;"></div>
      '''

  describe 'Error toggle view mixin', ->
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
      collection = new Chaplin.Collection {}
      if syncMachine
        _.extend collection.prototype, activeSyncMachine
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

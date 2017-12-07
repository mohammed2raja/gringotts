Chaplin = require 'chaplin'
ActiveSyncMachine = require 'mixins/models/active-sync-machine'
ServiceErrorReady = require 'mixins/views/service-error-ready'

class CollectionViewMock extends ServiceErrorReady Chaplin.CollectionView
  getTemplateFunction: ->
    -> '''
      <div class="service-error"></div>
      <div class="error"></div>
    '''

class CollectionMock extends ActiveSyncMachine Chaplin.Collection

describe 'ServiceErrorReady', ->
  view = null
  collection = null

  serviceAssertions = (selector = '.service-error') ->
    it 'should hide the error element by default', ->
      expect(view.$ selector).to.have.css 'display', 'none'

    context 'when collection is unsynced due to error', ->
      beforeEach ->
        collection.trigger 'unsynced'

      it 'should shows the error element', ->
        expect(view.$ selector).to.not.have.css 'display', 'none'

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

    context 'on unhandled error', ->
      error = null

      beforeEach ->
        sinon.spy view, 'notifyError'
        view.handleError error = status: 500

      it 'should not show notification', ->
        expect(view.notifyError).to.have.not.been.calledOnce
        expect(view.$ selector).to.not.have.css 'display', 'none'

      it 'should handle error', ->
        expect(error.errorHandled).to.be.true

  beforeEach ->
    collection = new CollectionMock()
    view = new CollectionViewMock {collection}

  afterEach ->
    view.dispose()
    collection.dispose()

  serviceAssertions()

  context 'with error selector', ->
    before ->
      CollectionViewMock::errorSelector = '.error'

    after ->
      delete CollectionViewMock::errorSelector

    serviceAssertions '.error'

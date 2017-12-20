import Chaplin from 'chaplin'
import helper from 'lib/mixin-helper'
import Paginated from 'mixins/models/paginated'
import SyncKey from 'mixins/models/sync-key'
import ForcedReset from 'mixins/models/forced-reset'
import Queryable from 'mixins/models/queryable'

class PaginatedCollectionMock extends Paginated Chaplin.Collection
  syncKey: 'someItems'
  urlRoot: '/test'

describe 'Paginated mixin', ->
  sandbox = null
  collection = null

  beforeEach ->
    sandbox = sinon.sandbox.create useFakeServer: yes
    collection = new PaginatedCollectionMock [{}, {}, {}]

  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should have proper mixins applied', ->
    expect(helper.instanceWithMixin collection, Queryable).to.be.true
    expect(helper.instanceWithMixin collection, SyncKey).to.be.true
    expect(helper.instanceWithMixin collection, ForcedReset).to.be.true

  it 'should have initial models', ->
    expect(collection.models).to.be.a.lengthOf 3

  context 'fetching', ->
    infinite = null
    promise = null

    beforeEach ->
      collection.count = 1000
      collection.infinite = infinite
      promise = collection.fetch()
      return

    it 'should reset models', ->
      expect(collection.models).to.be.a.lengthOf 0

    context 'on done', ->
      beforeEach ->
        sandbox.server.respondWith JSON.stringify
          count: 3
          someItems: [{}, {}, {}]
          next_page_id: 555
        sandbox.server.respond()
        promise

      it 'should query the server with the default query params', ->
        request = _.last sandbox.server.requests
        _.each ['page=1', 'per_page=30'], (i) ->
          expect(request.url).to.contain i

      it 'should parse response correctly', ->
        expect(collection.count).to.equal 3
        expect(collection.length).to.equal 3
        expect(collection.nextPageId).to.be.undefined

      context 'when pagination is infinite', ->
        before ->
          infinite = true

        after ->
          infinite = false

        it 'should read next page id', ->
          expect(collection.nextPageId).to.equal 555

    context 'on fail', ->
      catchSpy = null

      beforeEach ->
        sandbox.server.respondWith [500, {}, '{}']
        sandbox.server.respond()
        promise.catch catchSpy = sinon.spy()

      it 'should reset count to 0', ->
        expect(collection.count).to.equal 0

      it 'should pass error down the chain', ->
        expect(catchSpy).to.have.been.calledOnce

    context 'on abort', ->
      beforeEach ->
        promise.abort().catch ($xhr) ->
          $xhr unless $xhr.statusText is 'abort'

      it 'should not reset count', ->
        expect(collection.count).to.equal 1000

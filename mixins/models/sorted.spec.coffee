import Chaplin from 'chaplin'
import helper from '../../lib/mixin-helper'
import Sorted from './sorted'
import ForcedReset from './forced-reset'
import Queryable from './queryable'

class MockSortedCollection extends Sorted Chaplin.Collection
  urlRoot: '/test'

describe 'Sorted mixin', ->
  sandbox = null
  collection = null

  beforeEach ->
    sandbox = sinon.createSandbox useFakeServer: yes
    collection = new MockSortedCollection()

  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should be instantiated', ->
    expect(collection).to.be.instanceOf MockSortedCollection

  it 'should have proper mixins applied', ->
    expect(helper.instanceWithMixin collection, Queryable).to.be.true
    expect(helper.instanceWithMixin collection, ForcedReset).to.be.true

  context 'fetching', ->
    beforeEach ->
      collection.fetch()
      sandbox.server.respondWith [200, {}, JSON.stringify [{}, {}, {}]]
      sandbox.server.respond()

    it 'should query the server with the default query', ->
      request = _.last sandbox.server.requests
      expect(request.url).to.contain 'order=desc'

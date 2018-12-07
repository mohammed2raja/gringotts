import Chaplin from 'chaplin'
import Backbone from 'backbone'
import swissAjax from '../../lib/swiss-ajax'
import Queryable from './queryable'

class BaseCollection extends Chaplin.Collection

class CollectionMock extends Queryable BaseCollection
  DEFAULTS: _.extend {}, @::DEFAULTS, foo: 'moo', boo: 'goo'
  urlRoot: '/test'

testRequest = (request, expecting, notexpecting = []) ->
  _.each expecting, (exp) ->
    expect(request.url).to.contain exp
  _.each notexpecting, (notexp) ->
    expect(request.url).to.not.contain notexp

describe 'Queryable mixin', ->
  sandbox = null
  collection = null
  url = null

  beforeEach ->
    sandbox = sinon.createSandbox useFakeServer: true
    collection = new CollectionMock()

  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should be initialized', ->
    expect(collection).to.be.instanceOf CollectionMock
    expect(collection.query).to.be.eql {}

  context 'proxyQueryable', ->
    beforeEach ->
      collection.query = a: 1, b: 2

    it 'should return proper proxy', ->
      query = collection.proxyQueryable().getQuery
        inclDefaults: yes
        overrides: c: 3
      expect(query).to.eql a: 1, b: 2, c: 3, foo: 'moo', boo: 'goo'

    context 'trigerring queryChange event on collection', ->
      eventSpy = null
      proxyQueryable = null

      beforeEach ->
        proxyQueryable = collection.proxyQueryable()
        proxyQueryable.on 'queryChange', eventSpy = sandbox.spy()
        collection.setQuery x: 1, y: 2

      it 'should re-trigger even on proxy', ->
        expect(eventSpy).to.have.been.calledWith
          query: x: 1, y: 2
          diff: ['a', 'b', 'x', 'y']

      context 'on source collection disposing', ->
        beforeEach ->
          collection.dispose()

        it 'should dispose proxy', ->
          expect(proxyQueryable.disposed).to.be.true

      context 'when disposed', ->
        beforeEach ->
          proxyQueryable.dispose()
          collection.setQuery w: 1, e: 2

        it 'should not re-trigger collection events', ->
          expect(eventSpy).to.have.not.been.calledWith query: w: 1, e: 2

  context 'setting empty query', ->
    difference = null

    beforeEach ->
      difference = collection.setQuery {}

    it 'should return null difference for setQuery', ->
      expect(difference).to.be.null

  context 'setting the hash query', ->
    difference = null

    beforeEach ->
      collection.ignoreKeys = ['coo']
      difference = collection.setQuery foo: 1, boo: ['goo'], coo: 'hoo'
      collection.fetch()
      sandbox.server.respond()

    it 'should return proper difference for setQuery call', ->
      expect(difference).to.eql ['foo', 'coo']

    it 'should fetch from the server with proper url', ->
      expecting = ['/test', '?', 'foo=1', 'boo=goo']
      request = _.last sandbox.server.requests
      testRequest request, expecting

    it 'should fetch without ignored keys', ->
      request = _.last sandbox.server.requests
      expect(request.url).to.not.contain 'coo=hoo'

    it 'should return ignored keys in getQuery result', ->
      query = collection.getQuery()
      expect(query.coo).to.eq 'hoo'

    it 'should ignore keys in getQuery result', ->
      query = collection.getQuery inclIgnored: no
      expect(query.coo).to.be.undefined

    context 'setting the same query again', ->
      beforeEach ->
        difference = collection.setQuery boo: ['goo'], foo: 1, coo: 'hoo'

      it 'should return null difference for setQuery call', ->
        expect(difference).to.be.null

    context 'setting the empty query', ->
      beforeEach ->
        difference = collection.setQuery {}

      it 'should return proper difference fo setQuery', ->
        expect(difference).to.eql ['foo', 'coo']

  context 'setting the string query', ->
    difference = null

    beforeEach ->
      difference = collection.setQuery 'boo=goo&coo=hoo'
      collection.fetch()
      sandbox.server.respond()

    it 'should return proper difference for setQuery', ->
      expect(difference).to.eql ['coo']

    it 'should update query properly', ->
      expect(collection.getQuery inclDefaults: yes).to
        .eql boo: 'goo', coo: 'hoo', foo: 'moo'

    it 'should fetch from the server with proper url', ->
      expecting = ['/test', '?', 'coo=hoo', 'boo=goo']
      request = _.last sandbox.server.requests
      testRequest request, expecting

  context 'changing event', ->
    spy = null

    beforeEach ->
      spy = sandbox.spy()
      collection.on 'queryChange', spy
      collection.setQuery a: 'b', c: 'd'

    afterEach ->
      collection.dispose()

    it 'should raise queryChange event', ->
      expect(spy).to.have.been.calledOnce
      expect(spy).to.have.been.calledWith
        query: a: 'b', c: 'd'
        diff: ['a', 'c'],
        collection

    context 'setting the same query again', ->
      beforeEach ->
        collection.setQuery c: 'd', a: 'b'

      it 'should not raise queryChange event', ->
        expect(spy).to.have.been.calledOnce

    context 'setting the empty again', ->
      beforeEach ->
        collection.setQuery {}

      it 'should raise queryChange event', ->
        expect(spy).to.have.been.calledTwice
        expect(spy).to.have.been.calledWith
          query: {}
          diff: ['a', 'c'],
          collection

  context 'fetchWithQuery method', ->
    isUnsynced = null

    beforeEach ->
      collection.isUnsynced = -> isUnsynced
      collection.ignoreKeys = ['coo']
      sandbox.stub collection, 'fetch'

    context 'with query that has different keys', ->
      beforeEach ->
        collection.fetchWithQuery goo: 'aaa', coo: 'hoo'

      it 'should set query', ->
        expect(collection.getQuery()).to.eql goo: 'aaa', coo: 'hoo'

      it 'should fetch collection', ->
        expect(collection.fetch).to.have.been.calledOnce

    context 'with query that has only ignored keys', ->
      beforeEach ->
        collection.fetchWithQuery coo: 'noo'

      it 'should set query', ->
        expect(collection.getQuery()).to.eql coo: 'noo'

      it 'should not fetch collection', ->
        expect(collection.fetch).to.not.have.been.calledOnce

      context 'but collection was not synced yet', ->
        before ->
          isUnsynced = true

        it 'should fetch collection', ->
          expect(collection.fetch).to.have.been.calledOnce

    context 'with query and options', ->
      beforeEach ->
        collection.fetchWithQuery {goo: 'aaa'}, {reset: true}

      it 'should set query', ->
        expect(collection.getQuery()).to.eql goo: 'aaa'

      it 'should fetch collection with options', ->
        expect(collection.fetch).to.have.been.calledWith reset: true

  context 'with default values', ->
    beforeEach ->
      collection.DEFAULTS = _.extend {}, CollectionMock::DEFAULTS
        , some_value: 5
      collection.setQuery other_value: 'a'

    it 'should return proper simple query', ->
      query = collection.getQuery()
      expect(query).to.eql other_value: 'a'

    it 'should return proper query with defaults', ->
      query = collection.getQuery inclDefaults: yes
      expect(query).to.eql other_value: 'a', some_value: 5
        , foo: 'moo', boo: 'goo'

  context 'with custom prefix', ->
    beforeEach ->
      collection.prefix = 'local'
      collection.setQuery local_page: 20, local_per_page: 15
        , some_global: 'a'
      collection.fetch()
      sandbox.server.respond()

    it 'should initialize query and alien query properly', ->
      expect(collection.query).to.eql page: 20, per_page: 15
      expect(collection.alienQuery).to.eql some_global: 'a'

    it 'should fetch from the server', ->
      request = _.last sandbox.server.requests
      expecting = ['/test', '?', 'page=20', 'per_page=15']
      notexpecting = ['some_global']
      testRequest request, expecting, notexpecting

    context 'on getting query', ->
      opts = null
      query = null

      beforeEach ->
        query = collection.getQuery opts or undefined

      it 'should return query with prefix keys', ->
        expect(query).to.eql local_page: 20, local_per_page: 15
          , some_global: 'a'

      context 'with usePrefix no option', ->
        before ->
          opts = usePrefix: no

        after ->
          opts = null

        it 'should return query with simple keys', ->
          expect(query).to.eql page: 20, per_page: 15

  context 'with complex urlRoot', ->
    urlRoots =
      array: ['/boo', '/foo', '/moo']
      hash: {items: '/boo', trash: '/foo', else: '/moo'}

    beforeEach ->
      Backbone.ajax = swissAjax.ajax

    afterEach ->
      Backbone.ajax = swissAjax.backboneAjax

    _.keys(urlRoots).forEach (key) ->
      context "of type #{key}", ->
        beforeEach ->
          collection.urlRoot = urlRoots[key]
          collection.setQuery a: 'b'
          collection.fetch()
          sandbox.server.respond()

        it 'should request proper urls', ->
          request = _.first sandbox.server.requests
          expecting = ['/boo', '?', 'a=b']
          testRequest request, expecting

  context 'when base class has string url', ->
    before ->
      BaseCollection::url = '/basetest'
      CollectionMock::urlRoot = null

    after ->
      delete BaseCollection::url
      CollectionMock::urlRoot = '/test'

    beforeEach ->
      collection.setQuery 'coo=hoo'
      collection.fetch()
      sandbox.server.respond()

    it 'should fetch from the server with proper url', ->
      expecting = ['/basetest', '?', 'foo=moo', 'boo=goo', 'coo=hoo']
      request = _.last sandbox.server.requests
      testRequest request, expecting

  context 'when base class has func url', ->
    before ->
      BaseCollection::url = -> '/basetest'
      CollectionMock::urlRoot = null

    after ->
      delete BaseCollection::url
      CollectionMock::urlRoot = '/test'

    beforeEach ->
      collection.setQuery 'coo=hoo'
      collection.fetch()
      sandbox.server.respond()

    it 'should fetch from the server with proper url', ->
      expecting = ['/basetest', '?', 'foo=moo', 'boo=goo', 'coo=hoo']
      request = _.last sandbox.server.requests
      testRequest request, expecting

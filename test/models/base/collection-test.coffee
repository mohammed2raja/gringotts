define (require) ->
  Chaplin = require 'chaplin'
  Backbone = require 'backbone'
  mixinCheck = require 'test/helpers/mixin-check'
  swissAjax = require 'lib/swiss-ajax'
  Collection = require 'models/base/collection'

  class MockCollection extends Collection
    DEFAULTS: _.extend {}, @::DEFAULTS, sort_by: 'attrA'
    syncKey: 'tests'
    urlRoot: '/test'

  testRequest = (expecting, request) ->
    _.each expecting, (expecting) ->
      expect(request.url).to.contain expecting

  describe 'Base Collection', ->
    sandbox = null
    collection = null
    collectionClass = null
    data = [
      {attrA: 'A', attrB: 'A', id: 3}
      {attrA: 'B', attrB: 'Z', id: 1}
      {attrA: 'A', attrB: 'Z', id: 2}
      {attrA: 'Z', attrB: 'A', id: 0}
    ]

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: true

    afterEach ->
      sandbox.restore()

    context 'initialization', ->
      beforeEach ->
        collection = new MockCollection()

      afterEach ->
        collection.dispose()

      it 'should have proper mixins applied', ->
        funcs = _.functions Collection::
        ['ActiveSyncMachine', 'SafeSyncCallback', 'ServiceErrorCallback',
        'Abortable', 'WithHeaders'].forEach (mixin) ->
          expect(funcs).to.include.members _.functions mixinCheck[mixin]::

      context 'proxyState', ->
        beforeEach ->
          collection.state = a: 1, b: 2

        it 'should return proper proxy', ->
          state = collection.proxyState.getState {c: 3}, inclDefaults: yes
          expect(state).to.eql {
            a: 1, b: 2, c: 3,
            order: 'desc', sort_by: 'attrA'
          }

    context 'sorting remotely', ->
      beforeEach ->
        collection = new MockCollection data

      afterEach ->
        collection.dispose()

      it 'should parse the server response correctly', ->
        results = collection.parse tests: data, count: 10
        expect(collection.count).to.eql 10
        expect(results).to.have.a.lengthOf 4
        expect(results[0]).to.not.be.empty

      context 'setting the state by force setting', ->
        beforeEach ->
          collection.ignoreKeys = ['boo']
          collection.setState foo: 1, boo: 2
          sandbox.server.respond()

        it 'should fetch from the server with proper url', ->
          expecting = ['/test', '?', 'sort_by=attrA', 'order=desc', 'foo=1']
          request = _.last sandbox.server.requests
          testRequest expecting, request

        it 'should fetch without ignored keys', ->
          request = _.last sandbox.server.requests
          expect(request.url).to.not.contain 'boo=2'

      context 'setting the state by changing state', ->
        beforeEach ->
          collection.setState {sort_by: 'attrB'}
          sandbox.server.respond()

        it 'should fetch from the server with proper url', ->
          expecting = ['/test', '?', 'sort_by=attrB', 'order=desc']
          testRequest expecting, _.last sandbox.server.requests

    context 'changing', ->
      spy = null

      beforeEach ->
        collection = new MockCollection()
        spy = sandbox.spy()
        collection.on 'stateChange', spy
        collection.setState {a:'b'}
        sandbox.server.respond()

      afterEach ->
        collection.dispose()

      it 'should raise stateChange event', ->
        expect(spy).to.have.been.calledWith collection, {a:'b'}

    context 'on fetch fail', ->
      beforeEach ->
        collection = new MockCollection data
        collection.setState {}
        sandbox.server.respondWith [500, {}, '{}']
        sandbox.server.respond()

      afterEach ->
        collection.dispose()

      it 'should reset all existing items', ->
        expect(collection.length).to.equal 0

    context 'with default values', ->
      beforeEach ->
        collection = new MockCollection data
        collection.DEFAULTS = _.extend {}, MockCollection::DEFAULTS
          , some_value: 5
        collection.setState other_value: 'a'
        sandbox.server.respond()

      it 'should return proper simple state', ->
        state = collection.getState()
        expect(state).to.eql other_value: 'a'

      it 'should return proper state with defaults', ->
        state = collection.getState {}, inclDefaults: yes
        expect(state).to.eql other_value: 'a', some_value: 5, order: 'desc'
          , sort_by: 'attrA'

    context 'with custom prefix', ->
      beforeEach ->
        collection = new MockCollection data
        collection.prefix = 'local'
        collection.setState local_page: 20, local_per_page: 15
          , some_global: 'a'
        sandbox.server.respond()

      afterEach ->
        collection.dispose()

      it 'should initialize state and alien state properly', ->
        expect(collection.state).to.eql page: 20, per_page: 15
        expect(collection.alienState).to.eql some_global: 'a'

      it 'should fetch from the server', ->
        request = _.last sandbox.server.requests
        expecting = ['/test', '?', 'page=20', 'per_page=15']
        testRequest expecting, request
        expect(request.url).to.not.contain 'some_global'

      context 'on getting state', ->
        opts = null
        state = null

        beforeEach ->
          state = collection.getState {}, opts

        it 'should return state with prefix keys', ->
          expect(state).to.eql local_page: 20, local_per_page: 15
            , some_global: 'a'

        context 'with usePrefix no option', ->
          before ->
            opts = usePrefix: no

          after ->
            opts = null

          it 'should return state with simple keys', ->
            expect(state).to.eql page: 20, per_page: 15

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
            collection = new MockCollection()
            collection.urlRoot = urlRoots[key]
            collection.setState a: 'b'
            sandbox.server.respond()

          afterEach ->
            collection.dispose()

          it 'should request proper urls', ->
            request = _.first sandbox.server.requests
            expecting = ['/boo', '?', 'a=b']
            testRequest expecting, request

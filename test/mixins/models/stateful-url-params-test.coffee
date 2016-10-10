define (require) ->
  Chaplin = require 'chaplin'
  Backbone = require 'backbone'
  swissAjax = require 'lib/swiss-ajax'
  StatefulUrlParams = require 'mixins/models/stateful-url-params'

  class MockCollection extends StatefulUrlParams Chaplin.Collection
    DEFAULTS: _.extend {}, @::DEFAULTS, foo: 'moo', boo: 'goo'
    urlRoot: '/test'

  testRequest = (request, expecting, notexpecting=[]) ->
    _.each expecting, (exp) ->
      expect(request.url).to.contain exp
    _.each notexpecting, (notexp) ->
      expect(request.url).to.not.contain notexp

  describe 'StatefulUrlParams mixin', ->
    sandbox = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: true
      collection = new MockCollection()

    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should be initialized', ->
      expect(collection).to.be.instanceOf MockCollection
      expect(collection.state).to.be.eql {}

    context 'proxyState', ->
      beforeEach ->
        collection.state = a: 1, b: 2

      it 'should return proper proxy', ->
        state = collection.proxyState().getState {c: 3}, inclDefaults: yes
        expect(state).to.eql a: 1, b: 2, c: 3, foo: 'moo', boo: 'goo'

      context 'trigerring stateChange event on collection', ->
        eventSpy = null
        proxyState = null

        beforeEach ->
          proxyState = collection.proxyState()
          proxyState.on 'stateChange', eventSpy = sandbox.spy()
          collection.setState x: 1, y: 2

        it 'should re-trigger even on proxy', ->
          expect(eventSpy).to.have.been.calledWith x: 1, y: 2

        context 'when disposed', ->
          beforeEach ->
            proxyState.dispose()
            collection.setState w: 1, e: 2

          it 'should not re-trigger collection events', ->
            expect(eventSpy).to.have.not.been.calledWith w: 1, e: 2

    context 'setting empty state', ->
      difference = null

      beforeEach ->
        difference = collection.setState {}

      it 'should return null difference for setState', ->
        expect(difference).to.be.null

    context 'setting the hash state', ->
      difference = null

      beforeEach ->
        collection.ignoreKeys = ['coo']
        difference = collection.setState foo: 1, boo: 'goo', coo: 'hoo'
        collection.fetch()
        sandbox.server.respond()

      it 'should return proper difference for setState call', ->
        expect(difference).to.eql ['foo', 'coo']

      it 'should fetch from the server with proper url', ->
        expecting = ['/test', '?', 'foo=1', 'boo=goo']
        request = _.last sandbox.server.requests
        testRequest request, expecting

      it 'should fetch without ignored keys', ->
        request = _.last sandbox.server.requests
        expect(request.url).to.not.contain 'coo=hoo'

      context 'setting the same state again', ->
        beforeEach ->
          difference = collection.setState boo: 'goo', foo: 1, coo: 'hoo'

        it 'should return null difference for setState call', ->
          expect(difference).to.be.null

      context 'setting the empty state', ->
        beforeEach ->
          difference = collection.setState {}

        it 'should return proper difference fo setState', ->
          expect(difference).to.eql ['foo', 'coo']

    context 'setting the string state', ->
      difference = null

      beforeEach ->
        difference = collection.setState 'boo=goo&coo=hoo'
        collection.fetch()
        sandbox.server.respond()

      it 'should return proper difference for setState', ->
        expect(difference).to.eql ['coo']

      it 'should update state properly', ->
        expect(collection.getState {}, inclDefaults: yes).to
          .eql boo: 'goo', coo: 'hoo', foo: 'moo'

      it 'should fetch from the server with proper url', ->
        expecting = ['/test', '?', 'coo=hoo', 'boo=goo']
        request = _.last sandbox.server.requests
        testRequest request, expecting

    context 'changing event', ->
      spy = null

      beforeEach ->
        spy = sandbox.spy()
        collection.on 'stateChange', spy
        collection.setState a: 'b', c: 'd'

      afterEach ->
        collection.dispose()

      it 'should raise stateChange event', ->
        expect(spy).to.have.been.calledOnce
        expect(spy).to.have.been.calledWith a: 'b', c: 'd', collection

      context 'setting the same state again', ->
        beforeEach ->
          collection.setState c: 'd', a: 'b'

        it 'should not raise stateChange event', ->
          expect(spy).to.have.been.calledOnce

      context 'setting the empty again', ->
        beforeEach ->
          collection.setState {}

        it 'should raise stateChange event', ->
          expect(spy).to.have.been.calledTwice
          expect(spy).to.have.been.calledWith {}, collection

    context 'with default values', ->
      beforeEach ->
        collection.DEFAULTS = _.extend {}, MockCollection::DEFAULTS
          , some_value: 5
        collection.setState other_value: 'a'

      it 'should return proper simple state', ->
        state = collection.getState()
        expect(state).to.eql other_value: 'a'

      it 'should return proper state with defaults', ->
        state = collection.getState {}, inclDefaults: yes
        expect(state).to.eql other_value: 'a', some_value: 5
          , foo: 'moo', boo: 'goo'

    context 'with custom prefix', ->
      beforeEach ->
        collection.prefix = 'local'
        collection.setState local_page: 20, local_per_page: 15
          , some_global: 'a'
        collection.fetch()
        sandbox.server.respond()

      it 'should initialize state and alien state properly', ->
        expect(collection.state).to.eql page: 20, per_page: 15
        expect(collection.alienState).to.eql some_global: 'a'

      it 'should fetch from the server', ->
        request = _.last sandbox.server.requests
        expecting = ['/test', '?', 'page=20', 'per_page=15']
        notexpecting = ['some_global']
        testRequest request, expecting, notexpecting

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

    context 'url overriding', ->
      beforeEach ->
        collection.setState coo: 'hoo'
        collection.fetch()
        sandbox.server.respond()

      it 'should override url with custom rootUrl', ->
        resultUrl = collection.url 'sneaky/url'
        expect(resultUrl.startsWith 'sneaky/url').to.be.true
        expect(resultUrl).to.have.string 'coo=hoo'

      it 'should override url with custom state', ->
        expect(collection.url 'nasty/url', doo: 'woo').
          to.equal 'nasty/url?doo=woo'

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
            collection.setState a: 'b'
            collection.fetch()
            sandbox.server.respond()

          it 'should request proper urls', ->
            request = _.first sandbox.server.requests
            expecting = ['/boo', '?', 'a=b']
            testRequest request, expecting

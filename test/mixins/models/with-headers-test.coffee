define (require) ->
  Chaplin = require 'chaplin'
  WithHeaders = require 'mixins/models/with-headers'

  class MockModel extends WithHeaders Chaplin.Model
    url: '/foo/url'

  class CustomSimpleMockModel extends WithHeaders Chaplin.Model
    url: '/foo/url'
    HEADERS: _.extend {}, @::HEADERS, 'X-FOO-ID': '700'

  class CustomFuncMockModel extends WithHeaders Chaplin.Model
    url: '/foo/url'
    originalHeaders: @::HEADERS
    HEADERS: ->
      @mockDeferred.then =>
        @resolveHeaders(@originalHeaders).then (headers) ->
          _.extend {}, headers, 'X-BOO-ID': '300'

    constructor: ->
      @mockDeferred = $.Deferred()

  describe 'WithHeaders mixin', ->
    model = null
    server = null

    beforeEach ->
      server = sinon.fakeServer.create()

    afterEach ->
      server.restore()

    context 'with default configuration', ->
      $xhr = null

      beforeEach (done) ->
        model = new MockModel()
        $xhr = model.fetch()
        _.defer done

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        request = _.last(server.requests)
        headers = request.requestHeaders
        expect(headers).to.have.property 'Content-Type', 'application/json'
        expect(headers).to.have.property 'Accept', 'application/json'
        expect(request).to.have.property 'withCredentials', true

      context 'without credentials', ->
        beforeEach (done) ->
          model.withCredentials = false
          model.fetch()
          _.defer done

        it 'should have request with proper xhrFields', ->
          request = _.last server.requests
          expect(request).to.have.property 'withCredentials', false

      context 'syncing without options', ->
        beforeEach (done) ->
          model.sync 'create', model
          _.defer done

        it 'should sync without options too', ->
          expect(_.last server.requests).to.have.property 'method', 'POST'

      context 'aborting request', ->
        beforeEach ->
          $xhr.abort()
          return

        it 'should abort fetch request', ->
          expect(_.last server.requests).to.have.property 'aborted', true

    context 'with simple custom configuration', ->
      beforeEach ->
        server.respondWith '{}'
        server.autoRespond = yes
        model = new CustomSimpleMockModel()
        model.fetch()

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        headers = _.last(server.requests).requestHeaders
        expect(headers).to.have.property 'X-FOO-ID', '700'

    context 'with complex custom (using function) configuration', ->
      promise = null

      beforeEach ->
        server.respondWith '{}'
        server.autoRespond = yes
        model = new CustomFuncMockModel()
        promise = model.fetch()
        return

      afterEach ->
        model.dispose()

      context 'when mock request is complete', ->
        beforeEach ->
          model.mockDeferred.resolve()
          promise

        it 'should apply headers to ajax request', ->
          headers = _.last(server.requests).requestHeaders
          expect(headers).to.have.property 'X-BOO-ID', '300'

      context 'when mock request is complete but model is disposed', ->
        beforeEach  ->
          model.dispose()
          model.mockDeferred.resolve()
          promise

        it 'should not make server requests', ->
          expect(server.requests).to.have.length 0

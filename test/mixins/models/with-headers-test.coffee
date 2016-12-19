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
        done()

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        headers = _.last(server.requests).requestHeaders
        expect(headers).to.have.property 'Content-Type', 'application/json'
        expect(headers).to.have.property 'Accept', 'application/json'

      it 'should sync without options too', ->
        model.sync 'create', model
        expect(_.last(server.requests).method).to.be.equal 'POST'

      context 'aborting request', ->
        beforeEach (done) ->
          $xhr.abort()
          done()

        it 'should abort fetch request', ->
          expect(_.last(server.requests).aborted).to.be.equal true

    context 'with simple custom configuration', ->
      beforeEach (done) ->
        model = new CustomSimpleMockModel()
        model.fetch()
        done()

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        headers = _.last(server.requests).requestHeaders
        expect(headers).to.have.property 'X-FOO-ID', '700'


    context 'with complex custom (using function) configuration', ->
      beforeEach (done) ->
        model = new CustomFuncMockModel()
        model.fetch()
        done()

      afterEach ->
        model.dispose()

      context 'when mock request is complete', ->
        beforeEach (done) ->
          model.mockDeferred.resolve().done()
          done()

        it 'should apply headers to ajax request', ->
          headers = _.last(server.requests).requestHeaders
          expect(headers).to.have.property 'X-BOO-ID', '300'

      context 'when mock request is complete but model is disposed', ->
        beforeEach (done) ->
          model.dispose()
          model.mockDeferred.resolve().done()
          done()

        it 'should not make server requests', ->
          expect(server.requests).to.have.length 0

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
      @resolveHeaders(@originalHeaders).then (headers) ->
        _.extend {}, headers, 'X-BOO-ID': '300'

  describe 'WithHeaders mixin', ->
    model = null
    server = null

    beforeEach ->
      server = sinon.fakeServer.create()

    afterEach ->
      server.restore()

    context 'with default configuration', ->
      $xhr = null

      beforeEach ->
        model = new MockModel()
        $xhr = model.fetch()
        return # to avoid passing Deferred to mocha runner

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
        beforeEach ->
          $xhr.abort()
          return # to avoid passing Deferred to mocha runner

        it 'should abort fetch request', ->
          expect(_.last(server.requests).aborted).to.be.equal true

    context 'with simple custom configuration', ->
      beforeEach ->
        model = new CustomSimpleMockModel()
        model.fetch()
        return # to avoid passing Deferred to mocha runner

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        headers = _.last(server.requests).requestHeaders
        expect(headers).to.have.property 'X-FOO-ID', '700'


    context 'with complex custom (using function) configuration', ->
      beforeEach ->
        model = new CustomFuncMockModel()
        model.fetch()
        return # to avoid passing Deferred to mocha runner

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        headers = _.last(server.requests).requestHeaders
        expect(headers).to.have.property 'X-BOO-ID', '300'

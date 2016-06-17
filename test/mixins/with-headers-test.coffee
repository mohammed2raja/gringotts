define (require) ->
  Chaplin = require 'chaplin'
  WithHeaders = require 'mixins/with-headers'

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
      model = new MockModel()
      model.fetch()
      return # to avoid passing Deferred to mocha runner

    afterEach ->
      server.restore()
      model.dispose()

    context 'with default configuration', ->
      beforeEach ->
        model = new MockModel()
        model.fetch()
        return # to avoid passing Deferred to mocha runner

      afterEach ->
        model.dispose()

      it 'should apply headers to ajax request', ->
        headers = _.last(server.requests).requestHeaders
        expect(headers).to.have.property 'Content-Type', 'application/json'
        expect(headers).to.have.property 'Accept', 'application/json'

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

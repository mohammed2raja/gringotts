import Chaplin from 'chaplin'
import deadDeferred from 'lib/dead-deferred'
import utils from 'lib/utils'
import WithHeaders from 'mixins/models/with-headers'

class ModelMock extends WithHeaders Chaplin.Model
  url: '/foo/url'

class CustomSimpleMockModel extends WithHeaders Chaplin.Model
  url: '/foo/url'
  HEADERS: _.extend {}, @::HEADERS, 'X-FOO-ID': '700'

class CustomFuncMockModel extends WithHeaders Chaplin.Model
  url: '/foo/url'
  HEADERS: ->
    @mockDeferred.then =>
      @resolveHeaders(utils.superValue(this, 'HEADERS')).then (headers) ->
        _.extend {}, headers, 'X-BOO-ID': '300'

  constructor: ->
    super arguments...
    @mockDeferred = $.Deferred()

describe 'WithHeaders mixin', ->
  sandbox = null
  model = null

  beforeEach ->
    sandbox = sinon.sandbox.create useFakeServer: yes
    sandbox.spy $, 'ajax'
    sandbox.server.respondWith '{}'

  afterEach ->
    sandbox.restore()

  context 'with default configuration', ->
    withoutCredentials = null

    beforeEach ->
      model = new ModelMock()
      model.withCredentials = false if withoutCredentials

    afterEach ->
      model.dispose()

    context 'fetch', ->
      options = null

      beforeEach ->
        model.fetch options

      it 'should apply headers to ajax request', ->
        request = _.last sandbox.server.requests
        headers = request.requestHeaders
        expect(headers).to.have.property 'Content-Type',
          'application/json;charset=utf-8'
        expect(headers).to.have.property 'Accept', 'application/json'
        expect(request).to.have.property 'withCredentials', true

      context 'with contentType set to false', ->
        before ->
          options = contentType: no

        after ->
          options = null

        it 'should not apply Content-Type header', ->
          expect($.ajax).to.have.been.calledWith sinon.match.
            has 'contentType', no

      context 'without credentials', ->
        before ->
          withoutCredentials = yes

        after ->
          withoutCredentials = null

        it 'should have request with proper xhrFields', ->
          request = _.last sandbox.server.requests
          expect(request).to.have.property 'withCredentials', false

    context 'sync without options', ->
      beforeEach  ->
        model.sync 'create', model

      it 'should sync without options too', ->
        expect(_.last sandbox.server.requests).to.have
          .property 'method', 'POST'

    context 'abort request', ->
      beforeEach (done) ->
        promise = model.fetch async: yes
        utils.waitUntil
          condition: -> sandbox.server.requests.length > 0
          then: ->
            promise.abort().catch ($xhr) ->
              $xhr unless $xhr.statusText is 'abort'
            done()

      it 'should abort fetch request', ->
        expect(_.last sandbox.server.requests).to.have
          .property 'aborted', true

  context 'with simple custom configuration', ->
    beforeEach ->
      model = new CustomSimpleMockModel()
      model.fetch()

    afterEach ->
      model.dispose()

    it 'should apply headers to ajax request', ->
      headers = _.last(sandbox.server.requests).requestHeaders
      expect(headers).to.have.property 'X-FOO-ID', '700'

  context 'with complex custom (using function) configuration', ->
    promise = null

    beforeEach ->
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
        headers = _.last(sandbox.server.requests).requestHeaders
        expect(headers).to.have.property 'X-BOO-ID', '300'

    context 'when mock request is complete but model is disposed', ->
      beforeEach  ->
        sandbox.stub(deadDeferred, 'create').callsFake ->
          $.Deferred().reject 'disposed'
        model.dispose()
        model.mockDeferred.resolve()
        promise.catch (err) -> err unless err is 'disposed'

      it 'should not make server requests', ->
        expect(sandbox.server.requests).to.have.length 0

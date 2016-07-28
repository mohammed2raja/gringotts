define (require) ->
  Backbone = require 'backbone'
  Chaplin = require 'chaplin'
  swissAjax = require 'lib/swiss-ajax'

  class MockModelString extends Chaplin.Model
    url: '/foo'

  class MockModelSingleArray extends Chaplin.Model
    url: ['/foo']

  class MockModelArray extends Chaplin.Model
    url: ['/aoo', '/boo', '/coo']
    # It's recommended to handle multiple data results in parse() method.
    # Normally the only instance of JSON object should be passed down to
    # Backbone Model class for further processing.
    parse: (resp) ->
      super _.extend {}, resp[0], resp[1], resp[2]

  class MockModelHash extends Chaplin.Model
    url: {aoo: '/aoo', boo: '/boo', coo: '/coo'}
    parse: (resp) ->
      super _.extend {}, resp.aoo, resp.boo, resp.coo

  factory =
    String: MockModelString
    SingleArray: MockModelSingleArray
    Array: MockModelArray
    Hash: MockModelHash

  describe 'swissAjax', ->
    server = null
    model = null

    beforeEach ->
      Backbone.ajax = swissAjax.ajax
      server = sinon.fakeServer.create()

    afterEach ->
      Backbone.ajax = swissAjax.backboneAjax
      server.restore()
      model.dispose()

    simpleUrlTypes = ['String', 'SingleArray']
    simpleUrlTypes.forEach (urlType) ->
      context "with url of #{urlType} type", ->
        beforeEach ->
          model = new factory["#{urlType}"]()
          model.fetch()
          server.respondWith JSON.stringify {key: 'value'}
          server.respond()

        it 'should make one call', ->
          expect(server.requests.length).to.equal 1
          expect(server.requests[0].url).to.equal '/foo'

        it 'should set model proper data', ->
          expect(model.get 'key').to.be.equal 'value'

    urlTypes = ['Array', 'Hash']
    urlTypes.forEach (urlType) ->
      context "with url of #{urlType} type", ->
        beforeEach ->
          model = new factory["#{urlType}"]()
          model.fetch()
          return # to avoid passing Deferred to mocha

        context 'on request success', ->
          beforeEach ->
            server.respondWith '/aoo', JSON.stringify {keyA: 'valueA'}
            server.respondWith '/boo', JSON.stringify {keyB: 'valueB'}
            server.respondWith '/coo', JSON.stringify {keyC: 'valueC'}
            server.respond()

          it 'should make all calls', ->
            expect(server.requests.length).to.equal 3
            expect(server.requests[0].url).to.equal '/aoo'
            expect(server.requests[1].url).to.equal '/boo'
            expect(server.requests[2].url).to.equal '/coo'

          it 'should set model proper data', ->
            expect(model.get 'keyA').to.be.equal 'valueA'
            expect(model.get 'keyB').to.be.equal 'valueB'
            expect(model.get 'keyC').to.be.equal 'valueC'

        context 'on request error', ->
          errorHandler = null

          beforeEach ->
            errorHandler = sinon.spy()
            model.on 'error', errorHandler
            server.respondWith '/aoo', '{}'
            server.respondWith '/boo', [500, {}, '{}']
            server.respondWith '/coo', [404, {}, '{}']
            server.respond()

          it 'should trigger all errors', ->
            expect(errorHandler).to.have.been.calledTwice
            expect(errorHandler).to.have.been.calledWith model,
              sinon.match.has 'status', 500
            expect(errorHandler).to.have.been.calledWith model,
              sinon.match.has 'status', 404

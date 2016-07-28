define (require) ->
  Chaplin = require 'chaplin'
  Abortable = require 'mixins/models/abortable'

  class MockModel extends Abortable Chaplin.Model

  describe 'Abortable', ->
    server = null
    model = null
    xhr = null

    beforeEach (done) ->
      server = sinon.fakeServer.create()
      model = new MockModel()
      model.url = 'abc'
      xhr = model.fetch()
      done()

    afterEach ->
      server.restore()
      model.dispose()

    it 'should set the currentXHR property', ->
      expect(model.currentXHR).to.eql xhr

    context 'on finish request', ->
      beforeEach ->
        server.respond()

      it 'should delete currentXHR property', ->
        expect(model.currentXHR).to.be.undefined

    context 'on second fetch', ->
      beforeEach (done) ->
        sinon.spy model.currentXHR, 'abort'
        model.fetch()
        done()

      it 'should abort the initial request', ->
        expect(model.currentXHR.abort).to.have.been.calledOne

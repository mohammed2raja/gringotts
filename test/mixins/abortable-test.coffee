define (require) ->
  Chaplin = require 'chaplin'
  utils = require '../../lib/utils'
  Abortable = require 'mixins/abortable'
  ActiveSyncMachine = require 'mixins/active-sync-machine'

  class WrongMockModel extends Abortable Chaplin.Model

  class MockModel extends Abortable ActiveSyncMachine Chaplin.Model

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

    context 'if applied to wrong superclass', ->
      it 'should fail initialization', ->
        wrongCall = -> new WrongMockModel()
        expect(wrongCall).to.throw Error

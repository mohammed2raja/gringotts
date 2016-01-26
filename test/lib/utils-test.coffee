define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'

  class MockCollection extends Chaplin.Collection
    _.extend @prototype, Chaplin.SyncMachine

  describe 'Utils lib', ->

    context 'tagBuilder', ->
      beforeEach ->
        @$el = $ utils.tagBuilder 'a', 'Everything is awesome!', href: '#'

      it 'should create the correct tag', ->
        expect(@$el).to.be 'a'

      it 'should contain the correct content', ->
        expect(@$el).to.contain 'Everything is awesome!'

      it 'should have the correct attributes', ->
        expect(@$el).to.have.attr 'href', '#'

      it 'should insert HTML', ->
        $myEl = $ utils.tagBuilder 'p', '<strong>Live!</strong>', null, no
        expect($myEl).to.have 'strong'

    it 'should check if objects are enumerable', ->
      obj = prop: 1
      expect(utils.isEnumerable obj, 'prop').to.be.true

    context 'parseJSON', ->
      beforeEach ->
        window.Raven =
          captureException: sinon.spy()
        @result = utils.parseJSON @value

      afterEach ->
        delete @result
        delete window.Raven

      describe 'with valid JSON', ->
        before ->
          @value = '{"key": "Brand New"}'

        after ->
          delete @value

        it 'should return the json', ->
          expect(@result).to.not.be.false
          expect(@result).to.have.property 'key', 'Brand New'

      describe 'with invalid JSON', ->
        before ->
          @value = 'invalid'

        after ->
          delete @value

        it 'should log an exception to Raven', ->
          expect(@result).to.be.false
          expect(Raven.captureException).to.have.been.called

        it 'should pass the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'invalid'

      describe 'with empty string', ->
        before ->
          @value = ''

        after ->
          delete @value

        it 'should pass the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'Empty string'

      describe 'with undefined', ->
        before ->
          @value = undefined

        after ->
          delete @value

        it 'should pass the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'undefined'

    describe 'initSyncMachine', ->
      collection = null

      beforeEach ->
        collection = new MockCollection()
        utils.initSyncMachine collection
        sinon.stub collection, 'beginSync'
        sinon.stub collection, 'finishSync'
        sinon.stub collection, 'unsync'
        collection.trigger 'request', collection

      it 'should start the sync', ->
        expect(collection.beginSync).to.be.calledOnce

      context 'on response', ->
        beforeEach -> collection.trigger 'sync', collection

        it 'should complete the sync with finishSync', ->
          expect(collection.finishSync).to.be.calledOnce

      context 'on error', ->
        beforeEach -> collection.trigger 'error', collection

        it 'should complete the sync with unsync', ->
          expect(collection.unsync).to.be.calledOnce

define (require) ->
  utils = require 'lib/utils'

  describe 'Utils lib', ->

    describe 'tagBuilder', ->
      beforeEach ->
        @$el = $ utils.tagBuilder 'a', 'Everything is awesome!', href: '#'

      it 'creates the correct tag', ->
        expect(@$el).to.be 'a'

      it 'contains the correct content', ->
        expect(@$el).to.contain 'Everything is awesome!'

      it 'has the correct attributes', ->
        expect(@$el).to.have.attr 'href', '#'

      it 'inserts HTML', ->
        $myEl = $ utils.tagBuilder 'p', '<strong>Live!</strong>', null, no
        expect($myEl).to.have 'strong'

    it 'checks if objects are enumerable', ->
      obj = prop: 1
      expect(utils.isEnumerable obj, 'prop').to.be.true

    describe 'parseJSON', ->
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

        it 'returns the json', ->
          expect(@result).to.not.be.false
          expect(@result).to.have.property 'key', 'Brand New'

      describe 'with invalid JSON', ->
        before ->
          @value = 'invalid'

        after ->
          delete @value

        it 'logs an exception to Raven', ->
          expect(@result).to.be.false
          expect(Raven.captureException).to.have.been.called

        it 'passes the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'invalid'

      describe 'with empty string', ->
        before ->
          @value = ''

        after ->
          delete @value

        it 'passes the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'Empty string'

      describe 'with undefined', ->
        before ->
          @value = undefined

        after ->
          delete @value

        it 'passes the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'undefined'

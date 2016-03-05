define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'

  describe 'Utils lib', ->
    $el = null

    context 'tagBuilder', ->
      beforeEach ->
        $el = $ utils.tagBuilder 'a', 'Everything is awesome!', href: '#'

      it 'should create the correct tag', ->
        expect($el).to.match 'a'

      it 'should contain the correct content', ->
        expect($el).to.contain 'Everything is awesome!'

      it 'should have the correct attributes', ->
        expect($el).to.have.attr 'href', '#'

      it 'should insert HTML', ->
        $myEl = $ utils.tagBuilder 'p', '<strong>Live!</strong>', null, no
        expect($myEl).to.have.html '<strong>Live!</strong>'

    it 'should check if objects are enumerable', ->
      obj = prop: 1
      expect(utils.isEnumerable obj, 'prop').to.be.true

    context 'parseJSON', ->
      result = null
      value = null

      beforeEach ->
        window.Raven =
          captureException: sinon.spy()
        result = utils.parseJSON value

      afterEach ->
        delete window.Raven

      describe 'with valid JSON', ->
        before -> value = '{"key": "Brand New"}'
        after -> value = null

        it 'should return the json', ->
          expect(result).to.not.be.false
          expect(result).to.have.property 'key', 'Brand New'

      describe 'with invalid JSON', ->
        before -> value = 'invalid'
        after -> value = null

        it 'should log an exception to Raven', ->
          expect(result).to.be.false
          expect(Raven.captureException).to.have.been.called

        it 'should pass the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'invalid'

      describe 'with empty string', ->
        before -> value = ''
        after -> value = null

        it 'should pass the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'Empty string'

      describe 'with undefined', ->
        before -> value = undefined
        after -> value = null

        it 'should pass the string that failed to parse', ->
          secondArg = Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'undefined'

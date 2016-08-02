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

    context 'parseJSON', ->
      result = null
      value = null

      beforeEach ->
        window.Raven =
          captureException: sinon.spy()
        result = utils.parseJSON value

      afterEach ->
        delete window.Raven

      context 'with valid JSON', ->
        before -> value = '{"key": "Brand New"}'
        after -> value = null

        it 'should return the json', ->
          expect(result).to.not.be.false
          expect(result).to.have.property 'key', 'Brand New'

      context 'with invalid JSON', ->
        before -> value = 'invalid'
        after -> value = null

        it 'should log an exception to Raven', ->
          expect(result).to.be.false
          expect(window.Raven.captureException).to.have.been.called

        it 'should pass the string that failed to parse', ->
          secondArg = window.Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'invalid'

      context 'with empty string', ->
        before -> value = ''
        after -> value = null

        it 'should pass the string that failed to parse', ->
          secondArg = window.Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'Empty string'

      context 'with undefined', ->
        before -> value = undefined
        after -> value = null

        it 'should pass the string that failed to parse', ->
          secondArg = window.Raven.captureException.lastCall.args[1]
          expect(secondArg).to.eql tags: str: 'undefined'

    context 'toBrowserDate', ->
      it 'should convert data to HTML5 date', ->
        date = utils.toBrowserDate '2016-07-18'
        expect(date).to.equal '2016-07-18'

    context 'toServerDate', ->
      it 'should parse a number', ->
        date = utils.toServerDate '2016-07-18'
        expect(date).to.match /^2016-07-18T([0-9\.\:])+Z$/

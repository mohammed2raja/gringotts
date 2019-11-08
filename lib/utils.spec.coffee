import Chaplin from 'chaplin'
import deadDeferred from './dead-deferred'
import {keys, urlJoin, tagBuilder, parseJSON, toBrowserDate,
  toServerDate, mix, waitUntil, abortable, disposable,
  excludeUrlParam, excludeUrlParams, compress, superValue} from './utils'

describe 'Utils lib', ->
  context 'urlJoin', ->
    it 'should correctly combine urls with protocol', ->
      url = urlJoin 'https://somedomain.com/', '', null, '/foo'
      expect(url).to.equal 'https://somedomain.com/foo'

    it 'should correctly combine regular urls', ->
      url = urlJoin 'moo', '', null, '/foo', 'oops'
      expect(url).to.equal 'moo/foo/oops'
      url = urlJoin '/a', 'b/', '/c'
      expect(url).to.equal '/a/b/c'
      url = urlJoin 'd', 'e', 'f/'
      expect(url).to.equal 'd/e/f/'
      url = urlJoin 'one', 44, false, null, 'two'
      expect(url).to.equal 'one/44/two'

    it 'should correctly combine weird urls', ->
      url = urlJoin '', '/foo'
      expect(url).to.equal '/foo'
      url = urlJoin '/', undefined, '/foo'
      expect(url).to.equal '/foo'
      url = urlJoin '/', 'foo'
      expect(url).to.equal '/foo'

  context 'tagBuilder', ->
    $el = null

    beforeEach ->
      $el = $ tagBuilder 'a', 'Everything is awesome!', href: '#'

    it 'should create the correct tag', ->
      expect($el).to.match 'a'

    it 'should contain the correct content', ->
      expect($el).to.contain 'Everything is awesome!'

    it 'should have the correct attributes', ->
      expect($el).to.have.attr 'href', '#'

    it 'should insert HTML', ->
      $myEl = $ tagBuilder 'p', '<strong>Live!</strong>', null, no
      expect($myEl).to.have.html '<strong>Live!</strong>'

  context 'parseJSON', ->
    result = null
    value = null

    beforeEach ->
      window.Raven =
        captureException: sinon.spy()
      result = parseJSON value

    afterEach ->
      delete window.Raven

    context 'with valid JSON', ->
      before ->
        value = '{"key": "Brand New"}'

      after ->
        value = null

      it 'should return the json', ->
        expect(result).to.not.be.false
        expect(result).to.have.property 'key', 'Brand New'

    context 'with invalid JSON', ->
      before ->
        value = 'invalid'

      after ->
        value = null

      it 'should log an exception to Raven', ->
        expect(result).to.be.false
        expect(window.Raven.captureException).to.have.been.called

      it 'should pass the string that failed to parse', ->
        secondArg = window.Raven.captureException.lastCall.args[1]
        expect(secondArg).to.eql tags: str: 'invalid'

    context 'with empty string', ->
      before ->
        value = ''

      after ->
        value = null

      it 'should pass the string that failed to parse', ->
        secondArg = window.Raven.captureException.lastCall.args[1]
        expect(secondArg).to.eql tags: str: 'Empty string'

    context 'with undefined', ->
      before ->
        value = undefined

      after ->
        value = null

      it 'should pass the string that failed to parse', ->
        secondArg = window.Raven.captureException.lastCall.args[1]
        expect(secondArg).to.eql tags: str: 'undefined'

  context 'toBrowserDate', ->
    it 'should convert data to HTML5 date', ->
      date = toBrowserDate '2016-07-18'
      expect(date).to.equal '2016-07-18'

  context 'toServerDate', ->
    it 'should parse a number', ->
      date = toServerDate '2016-07-18'
      expect(date).to.match /^2016-07-18T([0-9\.\:])+Z$/

  context 'abortable', ->
    xhr = null

    beforeEach ->
      xhr = $.Deferred()
      xhr.abort = sinon.spy -> xhr.reject()
      return

      context 'regular handlers', ->
        progressSpy = null
        thenSpy = null
        catchSpy = null
        promise = null

        beforeEach ->
          promise = abortable xhr,
            progress: progressSpy = sinon.spy()
            then: thenSpy = sinon.spy()
            catch: catchSpy = sinon.spy()
          return

        context 'on nofity', ->
          beforeEach ->
            xhr.notify(5).resolve()
            promise

          it 'should pass progress to promise', ->
            expect(progressSpy).to.have.been.calledWith 5

        context 'on resolve', ->
          beforeEach ->
            xhr.resolve 6
            promise

          it 'should pass resolved value to promise', ->
            expect(thenSpy).to.have.been.calledWith 6

        context 'on reject', ->
          beforeEach ->
            xhr.reject 7
            promise

          it 'should pass rejected value to promise', ->
            expect(catchSpy).to.have.been.calledWith 7

        context 'on abort', ->
          beforeEach ->
            promise.abort()

          it 'should abort xhr', ->
            expect(xhr.abort).to.have.been.calledOnce

      context 'all handler', ->
        promise = null
        allSpy = null

        beforeEach ->
          promise = abortable xhr,
            all: allSpy = sinon.spy()
          return

        context 'on nofity', ->
          beforeEach ->
            xhr.notify(5).resolve()
            promise

          it 'should pass progress to promise', ->
            expect(allSpy).to.have.been.calledWith 5

        context 'on resolve', ->
          beforeEach ->
            xhr.resolve 6
            promise

          it 'should pass resolved value to promise', ->
            expect(allSpy).to.have.been.calledWith 6

        context 'on reject', ->
          beforeEach ->
            xhr.reject 7
            promise

          it 'should pass rejected value to promise', ->
            expect(allSpy).to.have.been.calledWith 7

  context 'disposable', ->
    expectCallback = (key, response, type) ->
      context key, ->
        sandbox = null
        promise = null
        callback = null
        disposed = null

        beforeEach ->
          sandbox = sinon.createSandbox useFakeServer: yes
          sandbox.server.respondWith response
          sandbox.stub(deadDeferred, 'create').callsFake ->
            $.Deferred().reject 'disposed'
          model = new Chaplin.Model()
          model.url = '/foo'
          promise = disposable model.fetch(), -> model.disposed
          promise[key] callback = sinon.spy()
          model.dispose() if disposed
          promise.catch ($xhr) ->
            $xhr unless $xhr is 'disposed' or $xhr.status is 500

        afterEach ->
          sandbox.restore()

        it 'should invoke promise callback', ->
          if type is 'success'
            expect(callback).to.be.calledWith [],
              sinon.match.string, sinon.match.has 'status', 200
          else
            expect(callback).to.be.calledWith sinon.match.has('status', 500),
              sinon.match.string, sinon.match.string

        context 'if disposed', ->
          before ->
            disposed = yes

          after ->
            disposed = null

          it 'should not invoke promise callback', ->
            if key in ['done', 'then']
              expect(callback).to.not.be.calledOnce
            else
              expect(callback).to.be.calledWith 'disposed'

    expectCallback 'done', '[]', 'success'
    expectCallback 'fail', [500, {}, '{}'], 'fail'
    expectCallback 'always', '[]', 'success'
    expectCallback 'then', '[]', 'success'
    expectCallback 'catch', [500, {}, '{}'], 'fail'

  context 'waitUntil', ->
    beforeEach (done) ->
      i = 0
      waitUntil
        condition: -> i++ > 5
        then: done

    it 'should wait and then finish test', ->
      expect(true).to.be.true

  context 'excludeUrlParams', ->
    params = null
    result = null

    beforeEach ->
      result = excludeUrlParams 'some/url?a=b&c=d&e=f&g=h', params

    context 'one param', ->
      before ->
        params = 'e'

      it 'should return proper url', ->
        expect(result).to.equal 'some/url?a=b&c=d&g=h'

    context 'many params', ->
      before ->
        params = ['a', 'c', 'g']

      it 'should return proper url', ->
        expect(result).to.equal 'some/url?e=f'

  context 'compress', ->
    context 'passing undefined', ->
      it 'should return undefined', ->
        expect(compress undefined).to.be.undefined

    context 'passing single element array', ->
      it 'should return the element', ->
        expect(compress [5]).to.equal 5

    context 'passing multiple elements array', ->
      it 'should return the array', ->
        expect(compress [6, 7]).to.eql [6, 7]

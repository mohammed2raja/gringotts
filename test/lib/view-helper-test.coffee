define (require) ->
  Handlebars = require 'handlebars'
  utils = require 'lib/utils'
  viewHelper = require 'lib/view-helper'

  describe 'ViewHelper', ->
    hbsOptions = null

    beforeEach ->
      hbsOptions = {
        fn: ->
        inverse: ->
      }
      sinon.stub hbsOptions, 'fn'
      sinon.stub hbsOptions, 'inverse'

    afterEach ->
      hbsOptions = null

    # Handlebars always passes a final argument to helpers, that's why we pass
    # an empty object in the tests.
    context 'URL helper', ->
      beforeEach ->
        sinon.stub utils, 'reverse'
      afterEach ->
        utils.reverse.restore()

      it 'should work without arguments', ->
        Handlebars.helpers.url {}
        expect(utils.reverse).to.be.calledOnce

      it 'should properly format URLs with params', ->
        Handlebars.helpers.url 'route', 'params', {}
        expect(utils.reverse).to.be.calledWith 'route', ['params']

      it 'should properly format URLs with params as object', ->
        Handlebars.helpers.url 'route', {p1:1, p2:2}, {}
        expect(utils.reverse).to.be.calledWith 'route', {p1:1, p2:2}

      it 'should properly format URLs with params as array', ->
        Handlebars.helpers.url 'route', ['param1', 'param2'], {}
        expect(utils.reverse).to.be.calledWith 'route', ['param1', 'param2']

      it 'should properly format URLs without params', ->
        Handlebars.helpers.url 'path', {}
        expect(utils.reverse).to.be.calledWith 'path'

      it 'should be able to be called without a query', ->
        Handlebars.helpers.url 'path', 5, {}
        expect(utils.reverse).to.be.calledWith 'path', [5]

      it 'should pass the query along', ->
        Handlebars.helpers.url 'starbuck', null, 'rank=lt', {}
        expect(utils.reverse).to.be.calledWith 'starbuck', null, 'rank=lt'

      it 'should pass the handlebars hash into query', ->
        Handlebars.helpers.url 'route', 5, null, hash: p1: 1
        expect(utils.reverse).to.be.calledWith 'route', [5], p1: 1

    context 'icon helper', ->
      icon = null
      second = null

      beforeEach ->
        icon = Handlebars.helpers.icon 'uber', second

      afterEach ->
        icon = null

      it 'should create HTML element', ->
        expect($ icon.string).to.have.class 'uber-font'

      context 'with a string', ->
        before -> second = 'always'
        after -> second = null

        it 'should add classes', ->
          expect($ icon.string).to.have.class 'always'

      context 'with an object', ->
        before ->
          second = title: 'My Title'

        after ->
          second = null

        it 'should add attributes', ->
          expect($ icon.string).to.have.attr 'title', 'My Title'

    it 'should format date correctly', ->
      timeStamp = Handlebars.helpers.dateFormat '1969-12-31', 'l'
      expect(timeStamp).to.equal '12/31/1969'

    context 'mail helper', ->
      $el = null

      beforeEach ->
        $el = $ Handlebars.helpers.mailTo('<hax>').string

      it 'should escape the email', ->
        expect($el).to.contain '&lt;hax&gt;'

      it 'should create the HTML element', ->
        expect($el).to.match 'a'
        expect($el.attr 'href').to.contain 'mailto'

    context 'and operator', ->
      context 'with fn and inverse blocks', ->
        it 'should call inverse when containing a falsy value', ->
          Handlebars.helpers.and true, false, true, hbsOptions
          expect(hbsOptions.inverse).to.be.calledOnce

        it 'should call fn when containing no falsy values', ->
          Handlebars.helpers.and true, true, 1, 'yes', hbsOptions
          expect(hbsOptions.fn).to.be.calledOnce

      context 'without fn and inverse blocks', ->
        it 'should return false when containing a falsy value', ->
          expect(Handlebars.helpers.and true, true, false).to.eql false

        it 'should return true when containing all truthy values', ->
          expect(Handlebars.helpers.and true, 'yes', 1).to.eql.true

    context 'concat strings', ->
      result = null

      beforeEach ->
        result = Handlebars.helpers.concat 'str1', 'str2', 'str3', hbsOptions

      afterEach ->
        result = null

      it 'should concat strings', ->
        expect(result).to.eql 'str1str2str3'

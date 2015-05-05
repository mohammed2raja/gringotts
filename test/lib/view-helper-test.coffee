define (require) ->
  Handlebars = require 'handlebars'
  utils = require 'lib/utils'
  viewHelper = require 'lib/view-helper'

  describe 'View helper lib', ->

    # Handlebars always passes a final argument to helpers, that's why we pass
    # an empty object in the tests.
    describe 'URL helper', ->
      beforeEach ->
        sinon.stub utils, 'reverse'
      afterEach ->
        utils.reverse.restore()

      it 'properly formats URLs with params', ->
        Handlebars.helpers.url 'route', 'params', 'q=s', {}
        expect(utils.reverse).to.be.calledWith 'route', ['params']

      it 'properly formats URLs without params', ->
        Handlebars.helpers.url 'path', {}
        expect(utils.reverse).to.be.calledWith 'path'

      it 'can be called without a query', ->
        Handlebars.helpers.url 'path', 5, {}
        expect(utils.reverse).to.be.calledWith 'path', [5]

      it 'passes the query along', ->
        Handlebars.helpers.url 'starbuck', null, 'rank=lt', {}
        expect(utils.reverse).to.be.calledWith 'starbuck', [null], 'rank=lt'

    describe 'icon helper', ->
      beforeEach ->
        @icon = Handlebars.helpers.icon 'uber', @second

      afterEach ->
        delete @icon

      it 'creates HTML element', ->
        expect($ @icon.string).to.have.class 'uber-font'

      describe 'with a string', ->
        before ->
          @second = 'always'

        after ->
          delete @second

        it 'adds classes', ->
          expect($ @icon.string).to.have.class 'always'

      describe 'with an object', ->
        before ->
          @second = title: 'My Title'

        after ->
          delete @second

        it 'adds attributes', ->
          expect($ @icon.string).to.have.attr 'title', 'My Title'

    it 'formats date correctly', ->
      timeStamp = Handlebars.helpers.dateFormat 2048, 'l'
      expect(timeStamp).to.equal '12/31/1969'

    describe 'mail helper', ->
      beforeEach ->
        @$el = $ Handlebars.helpers.mailTo('<hax>').string

      it 'escapes the email', ->
        expect(@$el).to.contain '&lt;hax&gt;'

      it 'creates the HTML element', ->
        expect(@$el).to.be 'a'
        expect(@$el.attr 'href').to.contain 'mailto'

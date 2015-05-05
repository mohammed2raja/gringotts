define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  advice = require 'mixins/advice'
  scopeable = require 'mixins/scopeable'

  describe 'Scopeable mixin', ->
    beforeEach ->
      sinon.stub $, 'ajax'
      @collection = new Chaplin.Collection()
      @collection.syncKey = 'last'
      @collection.url = 'bender'
      @collection.DEFAULTS =
        level: 1
        elements: ['earth', 'water', 'fire']
        order: 'asc'
        sort_by: 'element'
      advice.call @collection
      scopeable.call @collection

    afterEach ->
      $.ajax.restore()
      @collection.dispose()

    it 'sends default params when none are specified', ->
      @collection.fetch()
      expect(@collection.params).to.deep.equal @collection.DEFAULTS

    it 'handles numeric parameters', ->
      query = 'level=10'
      @collection.fetch {query}
      expect(@collection.params).to.have.property 'level', 10

    it 'removes defaults for opts data', ->
      @collection.fetch query: 'order=desc&level=1'
      params = $.ajax.firstCall.args[0].data
      expect(params).to.have.property 'order', 'desc'
      expect(params).to.not.have.property 'level'

    it 'places params on the request opts', ->
      @collection.fetch query: 'sort_by=level'
      expect($.ajax.firstCall.args[0].data.sort_by).to.equal 'level'

    it 'extends existing options data', ->
      @collection.fetch query: 'sort_by=level', data: {rank: 'master'}
      ajaxData = $.ajax.firstCall.args[0].data
      expect(ajaxData.sort_by).to.equal 'level'
      expect(ajaxData.rank).to.equal 'master'

    it 'sends supplied params', ->
      @collection.fetch query: 'avatar=last'
      params = $.ajax.firstCall.args[0].data
      expect(params).to.have.property 'avatar', 'last'

    it 'can be used on multiple collections', ->
      @otherCollection = new Chaplin.Collection()
      @otherCollection.DEFAULTS = level: 2
      advice.call @otherCollection
      scopeable.call @otherCollection
      @collection.fetch()
      @otherCollection.fetch url: 'master'
      expect(@collection.params).to.deep.equal @collection.DEFAULTS
      expect(@otherCollection.params).to.have.property 'level', 2

    describe 'when query params are specified', ->
      beforeEach ->
        expect(@collection.params).to.be.undefined
        query = 'level=5&sort_by=element&order=desc'
        @collection.fetch {query}
        @expected =
          level: 5
          sort_by: 'element'
          order: 'desc'
          elements: ['earth', 'water', 'fire']

      it 'stores the params', ->
        expect(@collection.params).to.deep.equal @expected

    it 'sets up array parameters', ->
      query = 'elements=earth&elements=water&sort_by=element'
      @collection.fetch {query}
      expect(@collection.params.elements).to.include.members ['earth', 'water']
        .and.to.not.include 'fire'


    describe 'scopedUrl', ->
      beforeEach ->
        sinon.stub utils, 'reverse', (name, params, query) ->
          "/ent/#{name}?#{Chaplin.utils.queryParams.stringify query}"
        @collection.fetch()

      afterEach ->
        utils.reverse.restore()

      it 'generates the correct query string', ->
        url = @collection.scopedUrl level: 2, sort_by: 'severity'
        expect(url).to.contain 'level=2'
          .and.to.contain 'sort_by=severity'

      # NOTE: Negations are sticky when chaining expectations.
      # https://github.com/chaijs/chai/issues/256
      it 'leaves defaults out', ->
        elements = ['earth', 'water', 'fire']
        url = @collection.scopedUrl {level: 1, elements}
        expect(url).to.not.contain 'level=1'
         .and.to.not.contain 'elements'

      it 'includes parameters from an array', ->
        url = @collection.scopedUrl elements: ['earth', 'water']
        expect(url).to.contain 'elements=earth'
          .and.to.contain 'elements=water'

      it 'is agnostic to array order', ->
        url = @collection.scopedUrl elements: ['water', 'earth', 'fire']
        expect(url).not.to.contain 'elements=earth'
          .and.not.to.contain 'elements=water'
          .and.not.to.contain 'elements=fire'

      it 'uses extra params passed in', ->
        url = @collection.scopedUrl {alignment: 'questionable'}
        expect(url).to.contain 'alignment=questionable'

      it 'reverses order if column is currently being sorted', ->
        @collection.params.order = 'asc'
        @collection.params.sort_by = 'severity'
        url = @collection.scopedUrl sort_by: 'severity'
        expect(url).to.contain 'order=desc'

      it 'uses the syncKey as the URL base', ->
        @collection.syncKey = 'metal'
        scopeable.call @collection
        url = @collection.scopedUrl {}
        expect(url).to.contain 'metal'

      describe 'with a getPageURL method', ->
        beforeEach ->
          @collection.getPageURL = sinon.spy()
          @collection.scopedUrl page: 2

        it 'uses that instead of utils', ->
          expect(utils.reverse).to.not.have.been.called
          expect(@collection.getPageURL).to.have.been.calledWith page: 2

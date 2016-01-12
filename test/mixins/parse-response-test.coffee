define (require) ->
  Chaplin = require 'chaplin'
  parseResponse = require 'mixins/parse-response'

  describe 'Parse response mixin', ->
    beforeEach ->
      @opts = {terror: [{}], count: "3"}
      @collection = new Chaplin.Collection()
      @collection.syncKey = 'terror'
      parseResponse.call @collection
      @results = @collection.parse @opts

    afterEach ->
      @collection.dispose()

    it 'sets the count on the collection', ->
      expect(@collection.count).to.equal 3

    it 'returns the object under the syncKey', ->
      expect(@results).to.have.lengthOf 1

    it 'parses a response normally if the collection has no syncKey', ->
      resp = sinon.spy()
      @collection.syncKey = null
      result = @collection.parse resp
      expect(result).to.equal resp

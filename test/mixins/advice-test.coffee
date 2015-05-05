define (require) ->
  advice = require 'mixins/advice'

  describe 'Advice mixin', ->
    beforeEach ->
      @obj ||= {}
      advice.call @obj

    it 'adds the correct methods', ->
      expect(@obj.after).to.exist
      expect(@obj.before).to.exist

    describe 'used on an object with methods', ->
      before ->
        @after = sinon.spy()
        @before = sinon.spy()
        @obj = {@after, @before}
      after ->
        _.each ['after', 'before', 'obj'], (obj) ->
          delete @[obj]
        , this

      it 'does not modify any methods', ->
        expect(@obj.after).to.eql @after
        expect(@obj.before).to.eql @before

define (require) ->
  advice = require 'mixins/advice'

  describe 'Advice mixin', ->
    obj = null

    beforeEach ->
      obj ||= {}
      advice.call obj

    it 'adds the correct methods', ->
      expect(obj.after).to.exist
      expect(obj.before).to.exist

    describe 'used on an object with methods', ->
      after = null
      before = null

      beforeEach ->
        after = sinon.spy()
        before = sinon.spy()
        obj = {after, before}

      it 'does not modify any methods', ->
        expect(obj.after).to.eql after
        expect(obj.before).to.eql before

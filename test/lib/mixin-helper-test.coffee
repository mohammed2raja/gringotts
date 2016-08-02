define (require) ->
  helper = require 'lib/mixin-helper'

  describe 'mixinHelper lib', ->
    context 'withMixin', ->
      target = null

      class S
        s: true
        id: -> 's'

      MixinA = (superclass) -> class A extends superclass
        helper.setTypeName @prototype, 'A'
        a: true
        id: ->
          super + 'a'

      MixinB = (superclass) -> class B extends superclass
        helper.setTypeName @prototype, 'B'
        b: true
        id: ->
          super + 'b'

      class T extends MixinA S
        t: true

      beforeEach ->
        target = new T()

      it 'should return true for target having MixinA', ->
        expect(helper.instanceWithMixin target, MixinA).to.be.true

      it 'should return false for target having MixinB', ->
        expect(helper.instanceWithMixin target, MixinB).to.be.false

      it 'should return true for class T having MixinA', ->
        expect(helper.classWithMixin T, MixinA).to.be.true

      it 'should return false for class T having MixinB', ->
        expect(helper.classWithMixin T, MixinB).to.be.false

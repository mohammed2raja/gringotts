import utils from 'lib/utils'
import helper from 'lib/mixin-helper'

describe 'MixinBuilder', ->
  context 'mix', ->
    target = null

    class S
      s: true
      id: -> 's'

    MixinA = (superclass) -> class A extends superclass
      helper.setTypeName @prototype, 'A'
      a: true
      id: ->
        super() + 'a'

    MixinB = (superclass) -> class B extends superclass
      helper.setTypeName @prototype, 'B'
      b: true
      id: ->
        super() + 'b'

    MixinC = (superclass) -> class C extends superclass
      helper.setTypeName @prototype, 'C'
      c: true
      id: ->
        super() + 'c'

    class T extends utils.mix(S).with MixinA, MixinB, MixinC
      t: true

    beforeEach ->
      target = new T()

    it 'should apply all mixin properties', ->
      expect(target.s).to.be.true
      expect(target.t).to.be.true
      expect(target.a).to.be.true
      expect(target.b).to.be.true
      expect(target.c).to.be.true

    it 'should override methods with mixins ones', ->
      expect(target.id()).to.be.equal 'sabc'

  context 'mix once', ->
    target = null

    class S
      s: true
      id: -> 's'

    MixinA = (superclass) -> class A extends superclass
      helper.setTypeName @prototype, 'A'
      a: true
      id: ->
        super() + 'a'

    MixinB =
      (superclass) -> class B extends utils.mix(superclass).with MixinA
        helper.setTypeName @prototype, 'B'
        b: true
        id: ->
          super() + 'b'

    MixinC =
      (superclass) -> class C extends utils.mix(superclass).with MixinA
        helper.setTypeName @prototype, 'C'
        c: true
        id: ->
          super() + 'c'

    class T extends MixinC MixinB S
      t: true

    beforeEach ->
      target = new T()

    it 'should apply all mixin properties', ->
      expect(target.s).to.be.true
      expect(target.t).to.be.true
      expect(target.a).to.be.true
      expect(target.b).to.be.true
      expect(target.c).to.be.true

    it 'should override methods with mixins ones', ->
      expect(target.id()).to.be.equal 'sabc'

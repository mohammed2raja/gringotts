helper = require 'lib/mixin-helper'

describe 'mixinHelper lib', ->
  context 'assertModel', ->
    it 'should throw error', ->
      expect(-> helper.assertModel {}).to.throw Error

  context 'assertNotModel', ->
    it 'should throw error', ->
      expect(-> helper.assertNotModel new Chaplin.Model()).to.throw Error

  context 'assertCollection', ->
    it 'should throw error', ->
      expect(-> helper.assertCollection {}).to.throw Error

  context 'assertNotCollection', ->
    it 'should throw error', ->
      expect(-> helper.assertNotCollection new Chaplin.Collection()) \
        .to.throw Error

  context 'assertModelOrCollection', ->
    it 'should throw error', ->
      expect(-> helper.assertModel {}).to.throw Error

  context 'assertView', ->
    it 'should throw error', ->
      expect(-> helper.assertView {}).to.throw Error

  context 'assertCollectionView', ->
    it 'should throw error', ->
      expect(-> helper.assertCollectionView {}).to.throw Error

  context 'assertViewOrCollectionView', ->
    it 'should throw error', ->
      expect(-> helper.assertViewOrCollectionView {}).to.throw Error

  context 'withMixin', ->
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

    class T extends MixinA S
      t: true

    beforeEach ->
      target = new T()

    it 'should return true for target having MixinA', ->
      expect(helper.instanceWithMixin target, MixinA).to.be.true

    it 'should return false for target having MixinB', ->
      expect(helper.instanceWithMixin target, MixinB).to.be.false

    it 'should return true for class T having MixinA', ->
      expect(helper.typeWithMixin T, MixinA).to.be.true

    it 'should return false for class T having MixinB', ->
      expect(helper.typeWithMixin T, MixinB).to.be.false

import unlessEqual from './unlessEqual'

describe 'unlessEqual helper', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions =
      fn: sinon.spy()
      inverse: sinon.spy()

  context 'with fn and inverse blocks', ->
    it 'should be true for non-equal values', ->
      unlessEqual 100, 200, hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

    it 'should be false for equal values', ->
      unlessEqual 100, 100, hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should be true for non-equal values', ->
      expect(unlessEqual 100, 200, {}).to.be.true

    it 'should be false for equal values', ->
      expect(unlessEqual 100, 100, {}).to.be.false

  context 'without arguments', ->
    it 'should fail with error', ->
      expect(-> unlessEqual {}).to.throw

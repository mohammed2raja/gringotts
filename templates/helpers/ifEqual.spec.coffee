import ifEqual from './ifEqual'

describe 'ifEqual helper', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions =
      fn: sinon.spy()
      inverse: sinon.spy()

  context 'with fn and inverse blocks', ->
    it 'should be true for equal values', ->
      ifEqual 100, 100, hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

    it 'should be false for non-equal values', ->
      ifEqual 100, 200, hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should be true for equal values', ->
      expect(ifEqual 100, 100, {}).to.be.true

    it 'should be false for non-equal values', ->
      expect(ifEqual 100, 200, {}).to.be.false

  context 'without arguments', ->
    it 'should fail with error', ->
      expect(-> ifEqual {}).to.throw

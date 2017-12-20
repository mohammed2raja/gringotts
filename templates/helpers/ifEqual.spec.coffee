import ifEqual from 'templates/helpers/ifEqual'

describe 'ifEqual helper', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions = {
      fn: ->
      inverse: ->
    }
    sinon.stub hbsOptions, 'fn'
    sinon.stub hbsOptions, 'inverse'

  afterEach ->
    hbsOptions = null

  context 'with fn and inverse blocks', ->
    it 'should be true for equal values', ->
      ifEqual 100, 100, hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

    it 'should be false for non-equal values', ->
      ifEqual 100, 200, hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should be true for equal values', ->
      expect(ifEqual 100, 100).to.be.true

    it 'should be false for non-equal values', ->
      expect(ifEqual 100, 200).to.be.false

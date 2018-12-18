import _or from './or'

describe 'or operator', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions =
      fn: sinon.spy()
      inverse: sinon.spy()

  context 'with fn and inverse blocks', ->
    it 'should call fn when containing a falsy value', ->
      _or true, false, true, hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

    it 'should call inverse when containing no falsy values', ->
      _or false, false, 0, '', hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should return true when containing a falsy value', ->
      expect(_or true, true, false, {}).to.eql true

    it 'should return false when containing all falsy values', ->
      expect(_or false, '', 0, {}).to.eql false

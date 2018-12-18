import _not from './not'

describe 'not operator', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions =
      fn: sinon.spy()
      inverse: sinon.spy()

  context 'with fn and inverse blocks', ->
    it 'should call inverse when containing a truthy value', ->
      _not true, false, true, hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

    it 'should call fn when containing no truthy values', ->
      _not false, 0, '', hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should return false when containing a truthy value', ->
      expect(_not true, false, {}).to.eql false

    it 'should return true when containing all falsy values', ->
      expect(_not false, '', 0, {}).to.eql true

import _and from 'templates/helpers/and'

describe 'and operator', ->
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
    it 'should call inverse when containing a falsy value', ->
      _and true, false, true, hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

    it 'should call fn when containing no falsy values', ->
      _and true, true, 1, 'yes', hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should return false when containing a falsy value', ->
      expect(_and true, true, false).to.eql false

    it 'should return true when containing all truthy values', ->
      expect(_and true, 'yes', 1).to.eql true

helpers = or: require 'templates/helpers/or'

describe 'or operator', ->
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
    it 'should call fn when containing a falsy value', ->
      helpers.or true, false, true, hbsOptions
      expect(hbsOptions.fn).to.be.calledOnce

    it 'should call inverse when containing no falsy values', ->
      helpers.or false, false, 0, '', hbsOptions
      expect(hbsOptions.inverse).to.be.calledOnce

  context 'without fn and inverse blocks', ->
    it 'should return true when containing a falsy value', ->
      expect(helpers.or true, true, false).to.eql true

    it 'should return false when containing all falsy values', ->
      expect(helpers.or false, '', 0).to.eql.false

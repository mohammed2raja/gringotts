helpers = array: require 'templates/helpers/array'

describe 'array helper', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions = {
      fn: ->
      inverse: ->
    }

  afterEach ->
    hbsOptions = null

  it 'should return array for arguments', ->
    result = helpers.array 10, 55, 647, hbsOptions
    expect(result).to.eql [10, 55, 647]

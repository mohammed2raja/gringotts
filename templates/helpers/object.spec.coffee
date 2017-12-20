import object from 'templates/helpers/object'

describe 'object helper', ->
  hbsOptions = null

  beforeEach ->
    hbsOptions = {
      fn: ->
      inverse: ->
    }

  afterEach ->
    hbsOptions = null

  it 'should return object for hash', ->
    result = object null,
      _.extend {}, hbsOptions, hash: {a: 10, b: 55}
    expect(result).to.eql {a: 10, b: 55}

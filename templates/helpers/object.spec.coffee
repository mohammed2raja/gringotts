import object from './object'

describe 'object helper', ->
  it 'should return object for hash', ->
    result = object null, hash: {a: 10, b: 55}
    expect(result).to.eql {a: 10, b: 55}

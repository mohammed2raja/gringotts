import array from './array'

describe 'array helper', ->
  it 'should return array for arguments', ->
    result = array 10, 55, 647, {}
    expect(result).to.eql [10, 55, 647]

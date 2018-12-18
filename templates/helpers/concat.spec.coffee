import concat from './concat'

describe 'concat strings', ->
  result = null

  beforeEach ->
    result = concat 'str1', 'str2', 'str3', {}

  it 'should concat strings', ->
    expect(result).to.eql 'str1str2str3'

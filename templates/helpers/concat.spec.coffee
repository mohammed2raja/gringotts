import concat from 'templates/helpers/concat'

describe 'concat strings', ->
  result = null
  hbsOptions = null

  beforeEach ->
    hbsOptions = {
      fn: ->
      inverse: ->
    }
    result = concat 'str1', 'str2', 'str3', hbsOptions

  afterEach ->
    hbsOptions = null
    result = null

  it 'should concat strings', ->
    expect(result).to.eql 'str1str2str3'

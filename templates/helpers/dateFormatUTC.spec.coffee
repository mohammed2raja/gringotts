import dateFormatUTC from 'templates/helpers/dateFormatUTC'

describe 'dateFormatUTC helper', ->
  it 'should format UTC date correctly with default input format', ->
    timeStamp = dateFormatUTC '1969-12-31T00:00:00.000Z', 'l', {}
    expect(timeStamp).to.equal '12/31/1969'

  it 'should format UTC date correctly with custom input format', ->
    timeStamp = dateFormatUTC '407116800', 'l', 'X', {}
    expect(timeStamp).to.equal '11/26/1982'

  it 'should return nothing if input value is falsy', ->
    timeStamp = dateFormatUTC null, 'l', {}
    expect(timeStamp).to.be.undefined

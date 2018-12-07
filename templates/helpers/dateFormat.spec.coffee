import dateFormat from './dateFormat'

describe 'dateFormat helper', ->
  it 'should format date correctly with default input format', ->
    timeStamp = dateFormat '1969-12-31', 'l', {}
    expect(timeStamp).to.equal '12/31/1969'

  it 'should format date correctly with custom input format', ->
    timeStamp = dateFormat '26/11/1982', 'l', 'DD/MM/YYYY', {}
    expect(timeStamp).to.equal '11/26/1982'

  it 'should return nothing if input value is falsy', ->
    timeStamp = dateFormat null, 'l', {}
    expect(timeStamp).to.be.undefined

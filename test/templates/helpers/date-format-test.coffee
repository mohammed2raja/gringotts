helpers = dateFormat: require 'templates/helpers/dateFormat'

describe 'Date format helper', ->
  it 'should format date correctly with default input format', ->
    timeStamp = helpers.dateFormat '1969-12-31', 'l', {}
    expect(timeStamp).to.equal '12/31/1969'

  it 'should format date correctly with custom input format', ->
    timeStamp = helpers.dateFormat '26/11/1982', 'l',
      'DD/MM/YYYY', {}
    expect(timeStamp).to.equal '11/26/1982'

  it 'should return nothing if input value is falsy', ->
    timeStamp = helpers.dateFormat null, 'l', {}
    expect(timeStamp).to.be.undefined

import mailTo from 'templates/helpers/mailTo'

describe 'mailTo helper', ->
  $el = null

  beforeEach ->
    $el = $ mailTo('<hax>').string

  it 'should escape the email', ->
    expect($el).to.contain '&lt;hax&gt;'

  it 'should create the HTML element', ->
    expect($el).to.match 'a'
    expect($el.attr 'href').to.contain 'mailto'

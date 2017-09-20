helpers = mailTo: require 'templates/helpers/mailTo'

describe 'mail helper', ->
  $el = null

  beforeEach ->
    $el = $ helpers.mailTo('<hax>').string

  it 'should escape the email', ->
    expect($el).to.contain '&lt;hax&gt;'

  it 'should create the HTML element', ->
    expect($el).to.match 'a'
    expect($el.attr 'href').to.contain 'mailto'

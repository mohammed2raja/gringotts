# Re-use application config file.
require {baseUrl: '../src'}, ['config'], ->
  require [
    'jquery'
    'test/dependencies'
    'test/templates'
  ], ->
    require.config
      paths:
        chai: '../vendor/bower/chai/chai'
        'chai-jquery': '../vendor/bower/chai-jquery/chai-jquery'
        sinon: '../vendor/bower/sinon/index'
        'sinon-chai': '../vendor/bower/sinon-chai/lib/sinon-chai'
      shim:
        'chai-jquery': ['jquery', 'chai']
        'sinon-chai': ['sinon', 'chai']

    require [
      'chai'
      'sinon-chai'
      'chai-jquery'
      'sinon'
    ], (chai, sinonChai, chaiJquery) ->
      # Create `window.describe` etc. for our BDD-like tests.
      mochaConfig = ui: 'bdd'
      mochaConfig.timeout = 0 unless window.PHANTOMJS
      mocha.setup mochaConfig
      chai.use sinonChai
      chai.use chaiJquery

      if window.PHANTOMJS
        blanket.options 'reporter',
          '../node_modules/grunt-blanket-mocha/support/grunt-reporter.js'

      if window.location.search.indexOf('cov=true') >= 0
        $('#change-coverage').on 'change', ->
          $("#blanket-main .rs:contains('100 %')")
            .parent(":not('.grand-total')").toggle()
      else
        $('label').hide()

      # Create another global variable for simpler syntax.
      window.expect = chai.expect

      # Dynamically require all test files.
      $.ajax(
        url: '../testSpecs.txt'
        dataType: 'text'
      )
      .done((data) ->
        specList = data.split '\n'
        # Remove blank line from end.
        specList.pop()
        specs = $.map specList, (spec) -> spec.replace '.coffee', ''
        require specs, ->
          mocha.run()
      )
      .fail ->
        console.log 'Failure with loading spec list! ', arguments
